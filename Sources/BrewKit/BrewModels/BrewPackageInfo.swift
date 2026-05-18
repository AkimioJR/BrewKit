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

    /// Display names for cask packages.
    /// cask 软件包的展示名称列表。
    public let names: [String]

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

    /// Historical cask tokens list.
    /// 历史 cask token 列表。
    public let oldTokens: [String]

    /// Formula pinned flag.
    /// formula pinned 标记。
    public let pinned: Bool?

    /// Pinned version string.
    /// pinned 版本字符串。
    public let pinnedVersion: String?

    /// Outdated flag.
    /// 是否可更新标记。
    public let outdated: Bool?

    /// Cask auto updates flag.
    /// cask 自动更新标记。
    public let autoUpdates: Bool?

    /// Formula license identifier.
    /// formula 许可证标识。
    public let license: String?

    /// Formula revision value.
    /// formula 修订版本值。
    public let revision: Int?

    /// Formula version scheme.
    /// formula 版本方案。
    public let versionScheme: Int?

    /// Formula compatibility version.
    /// formula 兼容性版本。
    public let compatibilityVersion: Int?

    /// Formula keg-only flag.
    /// formula keg-only 标记。
    public let kegOnly: Bool?

    /// Linked keg version.
    /// 当前链接 keg 版本。
    public let linkedKeg: String?

    /// Build dependencies.
    /// 构建依赖列表。
    public let buildDependencies: [String]

    /// Runtime dependencies.
    /// 运行时依赖列表。
    public let dependencies: [String]

    /// Test dependencies.
    /// 测试依赖列表。
    public let testDependencies: [String]

    /// Recommended dependencies.
    /// 推荐依赖列表。
    public let recommendedDependencies: [String]

    /// Optional dependencies.
    /// 可选依赖列表。
    public let optionalDependencies: [String]

    /// Requirements list.
    /// requirements 列表。
    public let requirements: [String]

    /// Conflicts list.
    /// 冲突软件包列表。
    public let conflictsWith: [String]

    /// Formula or cask download URL.
    /// formula 或 cask 下载 URL。
    public let url: String?

    /// Cask SHA256 checksum.
    /// cask SHA256 校验值。
    public let sha256: String?

    /// Cask install time (Unix timestamp).
    /// cask 安装时间（Unix 时间戳）。
    public let installedTime: Int?

    /// Cask bundle version.
    /// cask bundle version。
    public let bundleVersion: String?

    /// Cask short bundle version.
    /// cask short bundle version。
    public let bundleShortVersion: String?

    /// Cask language list.
    /// cask 语言列表。
    public let languages: [String]

    /// Formula/cask deprecated flag.
    /// formula/cask 废弃标记。
    public let deprecated: Bool?

    /// Formula/cask deprecation date.
    /// formula/cask 废弃日期。
    public let deprecationDate: String?

    /// Formula/cask deprecation reason.
    /// formula/cask 废弃原因。
    public let deprecationReason: String?

    /// Formula replacement after deprecation.
    /// 废弃后替代 formula。
    public let deprecationReplacementFormula: String?

    /// Cask replacement after deprecation.
    /// 废弃后替代 cask。
    public let deprecationReplacementCask: String?

    /// Formula/cask disabled flag.
    /// formula/cask 禁用标记。
    public let disabled: Bool?

    /// Formula/cask disable date.
    /// formula/cask 禁用日期。
    public let disableDate: String?

    /// Formula/cask disable reason.
    /// formula/cask 禁用原因。
    public let disableReason: String?

    /// Formula replacement after disable.
    /// 禁用后替代 formula。
    public let disableReplacementFormula: String?

    /// Cask replacement after disable.
    /// 禁用后替代 cask。
    public let disableReplacementCask: String?

    /// Formula post-install hook flag.
    /// formula post-install 钩子标记。
    public let postInstallDefined: Bool?

    /// Formula/cask autobump flag.
    /// formula/cask 自动 bump 标记。
    public let autobump: Bool?

    /// No-autobump message.
    /// no-autobump 提示信息。
    public let noAutobumpMessage: String?

    /// Skip livecheck flag.
    /// 跳过 livecheck 标记。
    public let skipLivecheck: Bool?

    /// Tap git head hash.
    /// tap git head 哈希。
    public let tapGitHead: String?

    /// Ruby source path.
    /// Ruby 源码路径。
    public let rubySourcePath: String?

    /// API generated date string.
    /// API 生成日期字符串。
    public let generatedDate: String?

    /// Variation keys available in API payload.
    /// API 载荷中包含的 variations 键列表。
    public let variationKeys: [String]
}
