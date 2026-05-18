import Foundation

/// Command execution result.
/// 命令执行结果。
public struct BrewCommandResult: Sendable {
    /// Standard output text.
    /// 标准输出文本。
    public let stdout: String

    /// Standard error text.
    /// 标准错误文本。
    public let stderr: String

    /// Process exit code.
    /// 进程退出码。
    public let exitCode: Int32

    /// Command duration in seconds.
    /// 命令耗时（秒）。
    public let duration: TimeInterval
}
