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
