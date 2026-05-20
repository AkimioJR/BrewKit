import Foundation

/// Structured search result grouped by package kind.
/// 按软件包类型分组的结构化搜索结果。
public struct BrewSearchResult: Codable, Sendable {
    /// Formula info list matched by query.
    /// 查询命中的 formula 信息列表。
    public let formulae: [BrewFormulaInfo]

    /// Cask info list matched by query.
    /// 查询命中的 cask 信息列表。
    public let casks: [BrewCaskInfo]
}
