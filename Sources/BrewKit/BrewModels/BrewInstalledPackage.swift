import Foundation

/// Installed package model.
/// 已安装软件包模型。
public struct BrewInstalledPackage: Codable, Sendable {
    /// Package token or formula name.
    /// 软件包 token 或 formula 名称。
    public let name: String

    /// Installed version string.
    /// 已安装版本字符串。
    public let version: String

    /// Package kind, formula or cask.
    /// 软件包类型，formula 或 cask。
    public let kind: BrewPackageKind

    /// Optional installation reason metadata.
    /// 可选的安装原因元数据。
    public let installReason: BrewInstallReason?
}
