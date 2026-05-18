import Foundation

/// Strongly typed package info returned by `BrewSession.info`.
/// `BrewSession.info` 返回的强类型软件包信息。
public struct BrewPackageInfo: Codable, Sendable {
    /// Package kind, formula or cask.
    /// 软件包类型，formula 或 cask。
    public let kind: BrewPackageKind

    /// Primary package name or token.
    /// 主软件包名称或 token。
    public let name: String

    /// Fully qualified package name.
    /// 完整限定软件包名称。
    public let fullName: String?

    /// Human readable package description.
    /// 人类可读的软件包描述。
    public let description: String?

    /// Package homepage URL.
    /// 软件包主页 URL。
    public let homepage: String?

    /// Tap source name.
    /// tap 来源名称。
    public let tap: String?

    /// Current version string.
    /// 当前版本字符串。
    public let version: String?

    /// Installed versions on current machine.
    /// 当前机器上的已安装版本列表。
    public let installedVersions: [String]

    /// Package aliases list.
    /// 软件包别名列表。
    public let aliases: [String]

    /// Historical package names list.
    /// 历史名称列表。
    public let oldNames: [String]

    /// Formula pinned flag.
    /// formula pinned 标记。
    public let pinned: Bool?

    /// Outdated flag.
    /// 是否可更新标记。
    public let outdated: Bool?

    /// Cask auto updates flag.
    /// cask 自动更新标记。
    public let autoUpdates: Bool?
}
