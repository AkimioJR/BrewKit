import Foundation

// MARK: - brew install

extension BrewSession {
    /// Installs one package.
    /// 安装一个软件包。
    /// - Parameter name: Package name to install.
    /// - 参数 name: 要安装的软件包名称。
    /// - Returns: Command execution result.
    /// - 返回值: 命令执行结果。
    public func install(_ name: String) async throws(BrewSessionError) -> BrewCommandResult {
        try await runCommand(args: ["install", name])
    }

    /// Installs one package and streams output lines.
    /// 安装一个软件包并流式输出逐行日志。
    /// - Parameter name: Package name to install.
    /// - 参数 name: 要安装的软件包名称。
    /// - Returns: Async stream of typed events carrying line text or `BrewSessionError`.
    /// - 返回值: 承载行文本或 `BrewSessionError` 的强类型异步事件流。
    public func installStream(_ name: String) -> BrewStream {
        streamCommand(args: ["install", name])
    }
}
