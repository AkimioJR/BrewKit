import Foundation

// MARK: - brew built-in commands

extension BrewSession {
    /// Runs one built-in Homebrew command and returns full process result.
    /// 运行一个 Homebrew 内置命令并返回完整进程结果。
    /// - Parameter command: Built-in command descriptor with mapped arguments.
    /// - 参数 command: 内置命令描述对象，包含映射后的参数。
    /// - Returns: Command execution result containing stdout, stderr, exit code and duration.
    /// - 返回值: 包含 stdout、stderr、退出码和耗时的命令执行结果。
    public func run(_ command: BrewBuiltinCommand) async throws(BrewSessionError) -> BrewCommandResult {
        try await runCommand(args: command.arguments)
    }
}
