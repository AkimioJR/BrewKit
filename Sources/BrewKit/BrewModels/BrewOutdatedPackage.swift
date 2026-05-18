import Foundation

/// Outdated package model.
/// 可更新软件包模型。
public struct BrewOutdatedPackage: Codable, Sendable {
    /// Package token or formula name.
    /// 软件包 token 或 formula 名称。
    public let name: String

    /// Installed versions detected on system.
    /// 系统检测到的已安装版本列表。
    public let installedVersions: [String]

    /// Latest available version.
    /// 最新可用版本。
    public let currentVersion: String

    /// Package kind, formula or cask.
    /// 软件包类型，formula 或 cask。
    public let kind: BrewPackageKind

    /// Whether formula is pinned.
    /// formula 是否被 pin。
    public let pinned: Bool
}
