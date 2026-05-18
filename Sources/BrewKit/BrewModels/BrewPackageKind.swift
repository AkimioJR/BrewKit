import Foundation

/// Package kind in Homebrew.
/// Homebrew 中的软件包类型。
public enum BrewPackageKind: String, Codable, Sendable {
    case formula
    case cask
}
