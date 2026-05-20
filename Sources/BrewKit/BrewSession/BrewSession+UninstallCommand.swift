import Foundation

// MARK: - brew uninstall

extension BrewSession {
    /// Uninstalls one package.
    /// 卸载一个软件包。
    /// - Parameter name: Package name to uninstall.
    /// - 参数 name: 要卸载的软件包名称。
    /// - Returns: Command execution result.
    /// - 返回值: 命令执行结果。
    public func uninstall(_ name: String) async throws(BrewSessionError) -> BrewCommandResult {
        try await runCommand(args: ["uninstall", name])
    }

    /// Uninstalls one package and streams output lines.
    /// 卸载一个软件包并流式输出逐行日志。
    /// - Parameter name: Package name to uninstall.
    /// - 参数 name: 要卸载的软件包名称。
    /// - Returns: Async stream of typed events carrying line text or `BrewSessionError`.
    /// - 返回值: 承载行文本或 `BrewSessionError` 的强类型异步事件流。
    public func uninstallStream(_ name: String) -> BrewStream {
        streamCommand(args: ["uninstall", name])
    }
}
