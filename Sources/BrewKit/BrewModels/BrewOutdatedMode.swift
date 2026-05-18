import Foundation

/// Outdated mode for brew outdated command.
/// brew outdated 命令的模式。
public enum BrewOutdatedMode: Sendable {
    /// Do not check for outdated packages.
    /// 不检查过时的软件包。
    case none

    /// Check for outdated packages, but do not include auto-updated packages.
    /// 检查过时的软件包，但不包括自动更新的软件包。
    case greedy

    /// Check for outdated packages, including auto-updated packages.
    /// 检查过时的软件包，包括自动更新的软件包。
    case greedyAutoUpdates
}
