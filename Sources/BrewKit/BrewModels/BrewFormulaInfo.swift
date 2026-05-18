import Foundation

/// Structured formula info model from `brew info --json=v2`.
/// 来自 `brew info --json=v2` 的结构化 formula 信息模型。
public struct BrewFormulaInfo: Codable, Sendable {
    /// Formula name.
    /// formula 名称。
    public let name: String

    /// Fully qualified formula name.
    /// 完整限定 formula 名称。
    public let fullName: String?

    /// Source tap name.
    /// 来源 tap 名称。
    public let tap: String?

    /// Historical names.
    /// 历史名称列表。
    public let oldnames: [String]?

    /// Formula aliases.
    /// formula 别名列表。
    public let aliases: [String]?

    /// Versioned formula names.
    /// 版本化 formula 名称列表。
    public let versionedFormulae: [String]?

    /// Human readable description.
    /// 可读描述文本。
    public let desc: String?

    /// Formula license.
    /// formula 许可证。
    public let license: String?

    /// Homepage URL.
    /// 主页 URL。
    public let homepage: String?

    /// Version object.
    /// 版本对象。
    public let versions: BrewFormulaVersions?

    /// Source URL object.
    /// 源地址对象。
    public let urls: BrewFormulaURLs?

    /// Revision number.
    /// 修订号。
    public let revision: Int?

    /// Version scheme number.
    /// 版本方案编号。
    public let versionScheme: Int?

    /// Compatibility version number.
    /// 兼容性版本编号。
    public let compatibilityVersion: Int?

    /// Autobump flag.
    /// 自动 bump 标记。
    public let autobump: Bool?

    /// No-autobump message.
    /// no-autobump 提示文本。
    public let noAutobumpMessage: String?

    /// Skip livecheck flag.
    /// 跳过 livecheck 标记。
    public let skipLivecheck: Bool?

    /// Bottle metadata.
    /// bottle 元数据。
    public let bottle: BrewFormulaBottle?

    /// Pour bottle guard condition.
    /// pour bottle 条件约束。
    public let pourBottleOnlyIf: BrewJSONValue?

    /// Keg-only flag.
    /// keg-only 标记。
    public let kegOnly: Bool?

    /// Keg-only reason.
    /// keg-only 原因。
    public let kegOnlyReason: BrewFormulaKegOnlyReason?

    /// Build options.
    /// 构建选项。
    public let options: [BrewJSONValue]?

    /// Build dependencies.
    /// 构建依赖。
    public let buildDependencies: [String]?

    /// Runtime dependencies.
    /// 运行时依赖。
    public let dependencies: [String]?

    /// Test dependencies.
    /// 测试依赖。
    public let testDependencies: [String]?

    /// Recommended dependencies.
    /// 推荐依赖。
    public let recommendedDependencies: [String]?

    /// Optional dependencies.
    /// 可选依赖。
    public let optionalDependencies: [String]?

    /// Dependencies provided by macOS.
    /// 由 macOS 提供的依赖。
    public let usesFromMacos: [String]?

    /// Bounds for macOS-provided dependencies.
    /// macOS 依赖边界约束。
    public let usesFromMacosBounds: [BrewJSONValue]?

    /// Requirement entries.
    /// requirement 条目列表。
    public let requirements: [BrewJSONValue]?

    /// Conflicting formula names.
    /// 冲突 formula 名称列表。
    public let conflictsWith: [String]?

    /// Conflict reason strings.
    /// 冲突原因字符串列表。
    public let conflictsWithReasons: [String]?

    /// Files to overwrite when linking.
    /// link 时可覆盖文件列表。
    public let linkOverwrite: [String]?

    /// Caveats text.
    /// caveats 文本。
    public let caveats: String?

    /// Installed entries.
    /// 已安装条目。
    public let installed: [BrewFormulaInstalledEntry]?

    /// Linked keg version.
    /// 已链接 keg 版本。
    public let linkedKeg: String?

    /// Pinned flag.
    /// pinned 标记。
    public let pinned: Bool?

    /// Outdated flag.
    /// outdated 标记。
    public let outdated: Bool?

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

    /// Post install hook defined flag.
    /// 已定义 post install 钩子标记。
    public let postInstallDefined: Bool?

    /// Service payload.
    /// service 载荷。
    public let service: BrewJSONValue?

    /// Tap git head hash.
    /// tap git head 哈希。
    public let tapGitHead: String?

    /// Ruby source file path.
    /// Ruby 源文件路径。
    public let rubySourcePath: String?

    /// Ruby source checksum.
    /// Ruby 源文件校验。
    public let rubySourceChecksum: BrewChecksum?

    /// Head dependency set.
    /// head 依赖集合。
    public let headDependencies: BrewFormulaDependencySet?

    /// Platform variations keyed by target tag.
    /// 按目标标签分组的平台变体。
    public let variations: [String: BrewFormulaVariation]?

    /// Exposed executable names.
    /// 暴露的可执行文件名。
    public let executables: [String]?

    /// Analytics payload.
    /// 统计数据载荷。
    public let analytics: BrewAnalytics?

    /// API generation date.
    /// API 生成日期。
    public let generatedDate: String?
}

/// Formula versions object.
/// formula 版本对象。
public struct BrewFormulaVersions: Codable, Sendable {
    /// Stable version.
    /// 稳定版版本号。
    public let stable: String?

    /// Head version marker.
    /// head 版本标记。
    public let head: String?

    /// Bottle availability flag.
    /// bottle 可用标记。
    public let bottle: Bool?
}

/// Formula URLs object.
/// formula URL 对象。
public struct BrewFormulaURLs: Codable, Sendable {
    /// Stable URL spec.
    /// stable URL 规格。
    public let stable: BrewFormulaStableURL?

    /// Head URL spec.
    /// head URL 规格。
    public let head: BrewFormulaHeadURL?
}

/// Formula stable URL definition.
/// formula stable URL 定义。
public struct BrewFormulaStableURL: Codable, Sendable {
    /// Download URL.
    /// 下载 URL。
    public let url: String?

    /// Git tag when applicable.
    /// 适用时的 Git tag。
    public let tag: String?

    /// Revision when applicable.
    /// 适用时的 revision。
    public let revision: String?

    /// Fetch strategy.
    /// 获取策略。
    public let using: String?

    /// Source checksum.
    /// 源码校验值。
    public let checksum: String?
}

/// Formula head URL definition.
/// formula head URL 定义。
public struct BrewFormulaHeadURL: Codable, Sendable {
    /// Repository URL.
    /// 仓库 URL。
    public let url: String?

    /// Branch name.
    /// 分支名。
    public let branch: String?

    /// Fetch strategy.
    /// 获取策略。
    public let using: String?
}

/// Formula bottle object.
/// formula bottle 对象。
public struct BrewFormulaBottle: Codable, Sendable {
    /// Stable bottle definition.
    /// stable bottle 定义。
    public let stable: BrewFormulaStableBottle?
}

/// Stable bottle metadata.
/// stable bottle 元数据。
public struct BrewFormulaStableBottle: Codable, Sendable {
    /// Rebuild count.
    /// rebuild 次数。
    public let rebuild: Int?

    /// Root registry URL.
    /// 根仓库 URL。
    public let rootUrl: String?

    /// Files keyed by platform tag.
    /// 按平台标签分组的文件元数据。
    public let files: [String: BrewFormulaBottleFile]?
}

/// Bottle file metadata.
/// bottle 文件元数据。
public struct BrewFormulaBottleFile: Codable, Sendable {
    /// Target cellar path.
    /// 目标 cellar 路径。
    public let cellar: String?

    /// Blob URL.
    /// 二进制 blob URL。
    public let url: String?

    /// Blob checksum.
    /// 二进制校验值。
    public let sha256: String?
}

/// Keg-only reason object.
/// keg-only 原因对象。
public struct BrewFormulaKegOnlyReason: Codable, Sendable {
    /// Reason summary.
    /// 原因摘要。
    public let reason: String?

    /// Detailed explanation.
    /// 详细解释。
    public let explanation: String?
}

/// Installed entry for formula tab information.
/// formula tab 的安装条目。
public struct BrewFormulaInstalledEntry: Codable, Sendable {
    /// Installed version.
    /// 已安装版本。
    public let version: String?

    /// Used build options.
    /// 已使用构建选项。
    public let usedOptions: [String]?

    /// Built-as-bottle flag.
    /// built_as_bottle 标记。
    public let builtAsBottle: Bool?

    /// Poured-from-bottle flag.
    /// poured_from_bottle 标记。
    public let pouredFromBottle: Bool?

    /// Install time.
    /// 安装时间戳。
    public let time: Int?

    /// Runtime dependencies.
    /// 运行时依赖。
    public let runtimeDependencies: [BrewFormulaRuntimeDependency]?

    /// Installed-as-dependency flag.
    /// installed_as_dependency 标记。
    public let installedAsDependency: Bool?

    /// Installed-on-request flag.
    /// installed_on_request 标记。
    public let installedOnRequest: Bool?
}

/// Runtime dependency entry.
/// 运行时依赖条目。
public struct BrewFormulaRuntimeDependency: Codable, Sendable {
    /// Dependency full name.
    /// 依赖完整名称。
    public let fullName: String?

    /// Installed dependency version.
    /// 已安装依赖版本。
    public let version: String?

    /// Declared-directly flag.
    /// declared_directly 标记。
    public let declaredDirectly: Bool?
}

/// Formula dependency set.
/// formula 依赖集合。
public struct BrewFormulaDependencySet: Codable, Sendable {
    /// Build dependencies.
    /// 构建依赖。
    public let buildDependencies: [String]?

    /// Runtime dependencies.
    /// 运行时依赖。
    public let dependencies: [String]?

    /// Test dependencies.
    /// 测试依赖。
    public let testDependencies: [String]?

    /// Recommended dependencies.
    /// 推荐依赖。
    public let recommendedDependencies: [String]?

    /// Optional dependencies.
    /// 可选依赖。
    public let optionalDependencies: [String]?

    /// Dependencies provided by macOS.
    /// 由 macOS 提供的依赖。
    public let usesFromMacos: [String]?

    /// Bounds for macOS-provided dependencies.
    /// macOS 依赖边界约束。
    public let usesFromMacosBounds: [BrewJSONValue]?
}

/// Formula variation object keyed by platform tags.
/// 按平台标签分组的 formula 变体对象。
public struct BrewFormulaVariation: Codable, Sendable {
    /// Build dependencies override.
    /// 构建依赖覆盖项。
    public let buildDependencies: [String]?

    /// Runtime dependencies override.
    /// 运行时依赖覆盖项。
    public let dependencies: [String]?

    /// Test dependencies override.
    /// 测试依赖覆盖项。
    public let testDependencies: [String]?

    /// Recommended dependencies override.
    /// 推荐依赖覆盖项。
    public let recommendedDependencies: [String]?

    /// Optional dependencies override.
    /// 可选依赖覆盖项。
    public let optionalDependencies: [String]?

    /// Dependencies provided by macOS override.
    /// 由 macOS 提供的依赖覆盖项。
    public let usesFromMacos: [String]?

    /// Bounds for macOS-provided dependencies override.
    /// macOS 依赖边界覆盖项。
    public let usesFromMacosBounds: [BrewJSONValue]?

    /// Head dependency override set.
    /// head 依赖覆盖集合。
    public let headDependencies: BrewFormulaDependencySet?
}

/// SHA256 checksum payload.
/// SHA256 校验载荷。
public struct BrewChecksum: Codable, Sendable {
    /// SHA256 string.
    /// SHA256 字符串。
    public let sha256: String?
}
