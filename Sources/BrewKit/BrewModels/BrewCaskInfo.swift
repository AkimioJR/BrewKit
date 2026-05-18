import Foundation

/// Structured cask info model from `brew info --json=v2`.
/// 来自 `brew info --json=v2` 的结构化 cask 信息模型。
public struct BrewCaskInfo: Codable, Sendable {
    /// Cask token.
    /// cask token。
    public let token: String

    /// Fully qualified token.
    /// 完整限定 token。
    public let fullToken: String?

    /// Display names.
    /// 展示名称列表。
    public let name: [String]?

    /// Historical tokens.
    /// 历史 token 列表。
    public let oldTokens: [String]?

    /// Human readable description.
    /// 可读描述文本。
    public let desc: String?

    /// Homepage URL.
    /// 主页 URL。
    public let homepage: String?

    /// Source tap name.
    /// 来源 tap 名称。
    public let tap: String?

    /// Download URL.
    /// 下载 URL。
    public let url: String?

    /// URL specs payload.
    /// URL 规格载荷。
    public let urlSpecs: [String: BrewJSONValue]?

    /// SHA256 checksum.
    /// SHA256 校验值。
    public let sha256: String?

    /// Container payload.
    /// 容器载荷。
    public let container: BrewJSONValue?

    /// Version string.
    /// 版本字符串。
    public let version: String?

    /// Installed version string.
    /// 已安装版本字符串。
    public let installed: String?

    /// Installed time.
    /// 安装时间戳。
    public let installedTime: Int?

    /// Bundle version.
    /// bundle 版本。
    public let bundleVersion: String?

    /// Bundle short version.
    /// bundle 短版本。
    public let bundleShortVersion: String?

    /// Auto-update flag.
    /// 自动更新标记。
    public let autoUpdates: Bool?

    /// Outdated flag.
    /// outdated 标记。
    public let outdated: Bool?

    /// Pinned flag.
    /// pinned 标记。
    public let pinned: Bool?

    /// Pinned version.
    /// pinned 版本。
    public let pinnedVersion: String?

    /// Deprecated flag.
    /// deprecated 标记。
    public let deprecated: Bool?

    /// Deprecation date.
    /// 废弃日期。
    public let deprecationDate: String?

    /// Deprecation reason.
    /// 废弃原因。
    public let deprecationReason: String?

    /// Formula replacement after deprecation.
    /// 废弃后的替代 formula。
    public let deprecationReplacementFormula: String?

    /// Cask replacement after deprecation.
    /// 废弃后的替代 cask。
    public let deprecationReplacementCask: String?

    /// Deprecation args payload.
    /// deprecate_args 载荷。
    public let deprecateArgs: BrewJSONValue?

    /// Disabled flag.
    /// disabled 标记。
    public let disabled: Bool?

    /// Disable date.
    /// 禁用日期。
    public let disableDate: String?

    /// Disable reason.
    /// 禁用原因。
    public let disableReason: String?

    /// Formula replacement after disable.
    /// 禁用后的替代 formula。
    public let disableReplacementFormula: String?

    /// Cask replacement after disable.
    /// 禁用后的替代 cask。
    public let disableReplacementCask: String?

    /// Disable args payload.
    /// disable_args 载荷。
    public let disableArgs: BrewJSONValue?

    /// Rename history.
    /// 重命名历史。
    public let rename: [String]?

    /// Languages.
    /// 语言列表。
    public let languages: [String]?

    /// Cask caveats.
    /// cask caveats 文本。
    public let caveats: String?

    /// Rosetta caveats.
    /// Rosetta caveats 文本。
    public let caveatsRosetta: String?

    /// Dependencies definition.
    /// 依赖定义对象。
    public let dependsOn: BrewCaskDependsOn?

    /// Conflicts definition.
    /// 冲突定义对象。
    public let conflictsWith: BrewCaskConflictsWith?

    /// Artifacts payload list.
    /// artifacts 载荷列表。
    public let artifacts: [BrewCaskArtifact]?

    /// Ruby source file path.
    /// Ruby 源文件路径。
    public let rubySourcePath: String?

    /// Ruby source checksum.
    /// Ruby 源文件校验。
    public let rubySourceChecksum: BrewChecksum?

    /// Tap git head hash.
    /// tap git head 哈希。
    public let tapGitHead: String?

    /// Skip livecheck flag.
    /// 跳过 livecheck 标记。
    public let skipLivecheck: Bool?

    /// Autobump flag.
    /// 自动 bump 标记。
    public let autobump: Bool?

    /// No-autobump message.
    /// no-autobump 提示文本。
    public let noAutobumpMessage: String?

    /// Platform variations keyed by target tag.
    /// 按目标标签分组的平台变体。
    public let variations: [String: BrewCaskVariation]?

    /// Analytics payload.
    /// 统计数据载荷。
    public let analytics: BrewAnalytics?

    /// API generation date.
    /// API 生成日期。
    public let generatedDate: String?
}

/// Cask depends_on object.
/// cask depends_on 对象。
public struct BrewCaskDependsOn: Codable, Sendable {
    /// Required formulae.
    /// 必需 formula 列表。
    public let formula: [String]?

    /// Required casks.
    /// 必需 cask 列表。
    public let cask: [String]?

    /// Architecture constraints.
    /// 架构约束。
    public let arch: [BrewJSONValue]?

    /// macOS constraints map.
    /// macOS 约束映射。
    public let macos: [String: [String]]?
}

/// Cask conflicts_with object.
/// cask conflicts_with 对象。
public struct BrewCaskConflictsWith: Codable, Sendable {
    /// Conflicting casks.
    /// 冲突 cask 列表。
    public let cask: [String]?

    /// Conflicting formulae.
    /// 冲突 formula 列表。
    public let formula: [String]?
}

/// Cask artifact object keyed by artifact kind.
/// 按 artifact 类型分组的 cask artifact 对象。
public typealias BrewCaskArtifact = [String: BrewJSONValue]

/// Cask variation object keyed by platform tags.
/// 按平台标签分组的 cask 变体对象。
public struct BrewCaskVariation: Codable, Sendable {
    /// Download URL override.
    /// 下载 URL 覆盖项。
    public let url: String?

    /// SHA256 override.
    /// SHA256 覆盖项。
    public let sha256: String?

    /// Artifacts override list.
    /// artifacts 覆盖列表。
    public let artifacts: [BrewCaskArtifact]?
}
