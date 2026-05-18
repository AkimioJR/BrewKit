import Foundation

/// Tap model in Homebrew.
/// Homebrew 的 tap 仓库模型。
public struct BrewTap: Codable, Sendable {
    /// Tap repository name.
    /// tap 仓库名。
    public let name: String
}
