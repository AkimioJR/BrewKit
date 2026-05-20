import Foundation

// MARK: - Command Execution Helpers

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

