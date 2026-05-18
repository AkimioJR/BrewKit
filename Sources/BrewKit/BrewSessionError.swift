import Foundation

/// Homebrew session errors thrown by BrewSession.
/// BrewSession 抛出的 Homebrew 会话错误。
public enum BrewSessionError: Error, Sendable {
    /// Brew executable not found after checking multiple candidates.
    /// 在检查多个候选路径后未找到 brew 可执行文件。
    case brewNotFound(candidates: [String])

    /// Invalid brew executable found at specified path.
    /// 在指定路径找到无效的 brew 可执行文件。
    case invalidBrewExecutable(path: String)

    /// Brew command failed with non-zero exit code or signal termination.
    /// Brew 命令以非零退出码或信号终止失败。
    case commandFailed(command: String, exitCode: Int32?, stdout: String, stderr: String)

    /// Brew command did not complete within the specified timeout.
    /// Brew 命令未在指定超时时间内完成。
    case commandTimedOut(command: String, timeout: TimeInterval)

    /// Failed to decode JSON output from brew command.
    /// 无法解码 brew 命令的 JSON 输出。
    case jsonDecodeFailed(command: String, payload: String)

    /// Current platform is not supported for brew path detection.
    /// 当前平台不支持 brew 路径检测。
    case unsupportedPlatform(os: String)

}

extension BrewSessionError: LocalizedError {
    /// Returns a human-readable description for the current error.
    /// 返回当前错误的人类可读描述。
    public var errorDescription: String? {
        switch self {
        case .brewNotFound(let candidates):
            return
                "brew executable not found. checked candidates: \(candidates.joined(separator: ", "))"
        case .invalidBrewExecutable(let path):
            return "invalid brew executable at path: \(path)"
        case .commandFailed(let command, let exitCode, _, let stderr):
            if let exitCode {
                return "brew command failed [\(exitCode)]: \(command)\n\(stderr)"
            }
            return "brew command failed: \(command)\n\(stderr)"
        case .commandTimedOut(let command, let timeout):
            return "brew command timed out after \(timeout)s: \(command)"
        case .jsonDecodeFailed(let command, _):
            return "failed to decode JSON output for command: \(command)"
        case .unsupportedPlatform(let os):
            return "unsupported platform for brew path detection: \(os)"
        }
    }
}
