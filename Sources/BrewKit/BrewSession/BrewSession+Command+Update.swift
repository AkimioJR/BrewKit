import Foundation

// MARK: - brew update

extension BrewSession {
    /// Runs `brew update` to update local metadata.
    /// 执行 `brew update` 以更新本地元数据。
    /// - Returns: Command execution result.
    /// - 返回值: 命令执行结果。
    public func updateDatabase() async throws(BrewSessionError) -> BrewCommandResult {
        try await runCommand(args: ["update"])
    }
}
