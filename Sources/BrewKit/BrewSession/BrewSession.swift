import Foundation

/// Homebrew session actor for typed CLI integration.
/// 用于类型化 CLI 集成的 Homebrew 会话 actor。
public actor BrewSession {
    public let timeout: TimeInterval

    let commandRunner: any BrewCommandRunning
    let environment: [String: String]
    let brewPathValue: String

    /// Creates a BrewSession with optional path and execution settings.
    /// 使用可选路径和执行配置创建 BrewSession。
    /// - Parameters:
    ///   - brewPath: Optional explicit brew executable path.
    ///   - environment: Environment overrides for brew commands.
    ///   - timeout: Default command timeout in seconds.
    /// - 参数:
    ///   - brewPath: 可选的 brew 可执行文件显式路径。
    ///   - environment: brew 命令的环境变量覆盖项。
    ///   - timeout: 默认命令超时时间（秒）。
    /// - Returns: A ready-to-use `BrewSession` actor instance.
    /// - 返回值: 可直接使用的 `BrewSession` actor 实例。
    public init(
        brewPath: String? = nil,
        environment: [String: String] = BrewSession.defaultEnvironment,
        timeout: TimeInterval = 30
    ) throws(BrewSessionError) {
        try self.init(
            brewPath: brewPath,
            environment: environment,
            timeout: timeout,
            commandRunner: ProcessCommandRunner()
        )
    }

    /// Creates a BrewSession with an injected command runner for tests.
    /// 使用注入命令执行器创建 BrewSession（用于测试）。
    /// - Parameters:
    ///   - brewPath: Optional explicit brew executable path.
    ///   - environment: Environment overrides for brew commands.
    ///   - timeout: Default command timeout in seconds.
    ///   - commandRunner: Injected command runner implementation.
    /// - 参数:
    ///   - brewPath: 可选的 brew 可执行文件显式路径。
    ///   - environment: brew 命令的环境变量覆盖项。
    ///   - timeout: 默认命令超时时间（秒）。
    ///   - commandRunner: 注入的命令执行器实现。
    /// - Returns: A ready-to-use `BrewSession` actor instance.
    /// - 返回值: 可直接使用的 `BrewSession` actor 实例。
    init(
        brewPath: String?,
        environment: [String: String],
        timeout: TimeInterval,
        commandRunner: any BrewCommandRunning
    ) throws(BrewSessionError) {
        self.timeout = timeout
        self.environment = environment
        self.commandRunner = commandRunner

        let resolvedPath: String
        if let brewPath {
            resolvedPath = brewPath
        } else {
            resolvedPath = try Self.autoDetectBrewPath()
        }

        guard FileManager.default.fileExists(atPath: resolvedPath),
            FileManager.default.isExecutableFile(atPath: resolvedPath)
        else {
            throw BrewSessionError.invalidBrewExecutable(path: resolvedPath)
        }

        self.brewPathValue = resolvedPath
    }

    /// Standard environment overrides for brew commands.
    /// brew 命令的标准环境覆盖项。
    public static let defaultEnvironment: [String: String] = [
        "PATH":
            "/opt/workbrew/sbin:/opt/workbrew/bin:/opt/homebrew/sbin:/opt/homebrew/bin:/usr/local/sbin:/usr/local/bin:/home/linuxbrew/.linuxbrew/bin:/usr/bin:/bin",
        "LANG": "en_US.UTF-8",
        "LC_ALL": "en_US.UTF-8",
        "HOMEBREW_NO_AUTO_UPDATE": "1",
    ]

    /// Returns the resolved brew executable path.
    /// 返回解析后的 brew 可执行文件路径。
    /// - Returns: Absolute brew executable path used by this session.
    /// - 返回值: 本会话使用的 brew 可执行文件绝对路径。
    public func brewPath() -> String {
        brewPathValue
    }
}

extension BrewSession {
    /// Executes brew command and maps non-zero exit code into `BrewSessionError`.
    /// 执行 brew 命令并将非零退出码映射为 `BrewSessionError`。
    /// - Parameter args: Brew command arguments without executable.
    /// - 参数 args: 不含可执行文件本身的 brew 命令参数。
    /// - Returns: Command execution result.
    /// - 返回值: 命令执行结果。
    func runCommand(args: [String]) async throws(BrewSessionError) -> BrewCommandResult {
        let command = commandString(args: args)

        let result = try await commandRunner.run(
            executable: brewPathValue,
            arguments: args,
            environment: environment,
            timeout: timeout,
            stream: nil
        )

        if result.exitCode != 0 {
            throw BrewSessionError.commandFailed(
                command: command,
                exitCode: result.exitCode,
                stdout: result.stdout,
                stderr: result.stderr
            )
        }

        return result
    }

    /// Creates stream-based command execution API for long-running operations.
    /// 为长耗时操作创建流式命令执行 API。
    /// - Parameter args: Brew command arguments without executable.
    /// - 参数 args: 不含可执行文件本身的 brew 命令参数。
    /// - Returns: Async stream of typed events carrying line text or `BrewSessionError`.
    /// - 返回值: 承载行文本或 `BrewSessionError` 的强类型异步事件流。
    func streamCommand(args: [String]) -> BrewStream {
        let brewPath = brewPathValue
        let environment = self.environment
        let timeout = self.timeout
        let runner = commandRunner
        let command = commandString(args: args)

        return AsyncStream { continuation in
            Task {
                do {
                    let result = try await runner.run(
                        executable: brewPath,
                        arguments: args,
                        environment: environment,
                        timeout: timeout,
                        stream: { line in
                            continuation.yield(.success(line))
                        }
                    )

                    if result.exitCode != 0 {
                        continuation.yield(
                            .failure(
                                BrewSessionError.commandFailed(
                                    command: command,
                                    exitCode: result.exitCode,
                                    stdout: result.stdout,
                                    stderr: result.stderr
                                )
                            )
                        )
                        continuation.finish()
                        return
                    }

                    continuation.finish()
                } catch {
                    let mappedError: BrewSessionError
                    if let brewError = error as? BrewSessionError {
                        mappedError = brewError
                    } else {
                        mappedError = .commandFailed(
                            command: command,
                            exitCode: nil,
                            stdout: "",
                            stderr: error.localizedDescription
                        )
                    }
                    continuation.yield(.failure(mappedError))
                    continuation.finish()
                }
            }
        }
    }

    /// Returns a shell-like command string for diagnostics.
    /// 返回用于诊断的类 shell 命令字符串。
    /// - Parameter args: Brew command arguments without executable.
    /// - 参数 args: 不含可执行文件本身的 brew 命令参数。
    /// - Returns: Joined command string.
    /// - 返回值: 拼接后的命令字符串。
    func commandString(args: [String]) -> String {
        ([brewPathValue] + args).joined(separator: " ")
    }
}
