import Foundation

// MARK: - brew tap / untap

extension BrewSession {
    /// Returns currently tapped repositories.
    /// 返回当前已 tap 的仓库。
    /// - Returns: Tapped repository list.
    /// - 返回值: 已 tap 仓库列表。
    public func taps() async throws(BrewSessionError) -> [BrewTap] {
        let result = try await runCommand(args: ["tap"])
        return Self.parseLineValues(result.stdout).map { BrewTap(name: $0) }
    }

    /// Taps one repository.
    /// tap 一个仓库。
    /// - Parameter repository: Repository name such as `homebrew/cask`.
    /// - 参数 repository: 仓库名称，例如 `homebrew/cask`。
    /// - Returns: Command execution result.
    /// - 返回值: 命令执行结果。
    public func tap(_ repository: String) async throws(BrewSessionError) -> BrewCommandResult {
        try await runCommand(args: ["tap", repository])
    }

    /// Untaps one repository.
    /// untap 一个仓库。
    /// - Parameter repository: Repository name such as `homebrew/cask`.
    /// - 参数 repository: 仓库名称，例如 `homebrew/cask`。
    /// - Returns: Command execution result.
    /// - 返回值: 命令执行结果。
    public func untap(_ repository: String) async throws(BrewSessionError) -> BrewCommandResult {
        try await runCommand(args: ["untap", repository])
    }
}
