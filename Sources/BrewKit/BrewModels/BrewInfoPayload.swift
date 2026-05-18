import Foundation

/// Root payload for `brew info --json=v2`.
/// `brew info --json=v2` 的根载荷。
public struct BrewInfoPayload: Codable, Sendable {
    /// Formula entries.
    /// formula 条目列表。
    public let formulae: [BrewFormulaInfo]

    /// Cask entries.
    /// cask 条目列表。
    public let casks: [BrewCaskInfo]
}
