import Foundation

// MARK: - brew --version

extension BrewSession {
    /// Returns `brew --version` output.
    /// 返回 `brew --version` 输出。
    /// - Returns: Trimmed version output text.
    /// - 返回值: 去除首尾空白后的版本输出文本。
    public func homebrewVersion() async throws(BrewSessionError) -> String {
        let result = try await runCommand(args: ["--version"])
        return result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
