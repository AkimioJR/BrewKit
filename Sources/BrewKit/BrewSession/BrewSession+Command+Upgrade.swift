import Foundation

// MARK: - brew upgrade

extension BrewSession {
    /// Upgrades one package.
    /// 升级一个软件包。
    /// - Parameter name: Package name to upgrade.
    /// - 参数 name: 要升级的软件包名称。
    /// - Returns: Command execution result.
    /// - 返回值: 命令执行结果。
    public func upgrade(_ name: String) async throws(BrewSessionError) -> BrewCommandResult {
        try await runCommand(args: ["upgrade", name])
    }

    /// Upgrades one package and streams output lines.
    /// 升级一个软件包并流式输出逐行日志。
    /// - Parameter name: Package name to upgrade.
    /// - 参数 name: 要升级的软件包名称。
    /// - Returns: Async stream of typed events carrying line text or `BrewSessionError`.
    /// - 返回值: 承载行文本或 `BrewSessionError` 的强类型异步事件流。
    public func upgradeStream(_ name: String) -> BrewStream {
        streamCommand(args: ["upgrade", name])
    }
}
