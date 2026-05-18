import Foundation

/// Install reason of a package.
/// 软件包的安装原因。
public enum BrewInstallReason: String, Codable, Sendable {
    /// Installed by user request.
    /// 用户请求安装。
    case onRequest = "on_request"

    /// Installed as a dependency.
    /// 作为依赖项安装。
    case dependency = "dependency"

    /// Unknown install reason.
    /// 未知安装原因。
    case unknown = "unknown"
}
