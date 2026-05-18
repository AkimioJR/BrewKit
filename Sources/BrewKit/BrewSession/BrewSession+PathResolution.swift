import Foundation

// MARK: - Path Resolution

extension BrewSession {
    /// Detects brew path using common platform-specific candidates and PATH lookup.
    /// 使用平台常见路径和 PATH 查找探测 brew 路径。
    /// - Returns: First valid executable path from probing order.
    /// - 返回值: 按探测顺序找到的第一个有效可执行路径。
    static func autoDetectBrewPath() throws(BrewSessionError) -> String {
        let candidates = try brewPathCandidates()

        for candidate in candidates {
            if FileManager.default.fileExists(atPath: candidate),
                FileManager.default.isExecutableFile(atPath: candidate)
            {
                return candidate
            }
        }

        throw BrewSessionError.brewNotFound(candidates: candidates)
    }

    /// Returns brew path candidates in probing order.
    /// 返回探测顺序下的 brew 路径候选项。
    /// - Returns: Ordered path candidates for brew detection.
    /// - 返回值: 用于 brew 探测的有序路径候选列表。
    static func brewPathCandidates() throws(BrewSessionError) -> [String] {
        #if os(macOS)
            return [
                "/opt/homebrew/bin/brew",
                "/usr/local/bin/brew",
            ] + lookupBrewInPATH()
        #elseif os(Linux)
            return [
                "/home/linuxbrew/.linuxbrew/bin/brew"
            ] + lookupBrewInPATH()
        #else
            throw BrewSessionError.unsupportedPlatform(
                os: ProcessInfo.processInfo.operatingSystemVersionString)
        #endif
    }

    /// Looks up brew in PATH using `/usr/bin/env which brew`.
    /// 使用 `/usr/bin/env which brew` 在 PATH 中查找 brew。
    /// - Returns: One-element array with resolved PATH brew, or empty array when unavailable.
    /// - 返回值: 找到时返回单元素数组，未找到时返回空数组。
    static func lookupBrewInPATH() -> [String] {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["which", "brew"]

        let output = Pipe()
        process.standardOutput = output
        process.standardError = Pipe()

        do {
            try process.run()
            process.waitUntilExit()
            guard process.terminationStatus == 0 else { return [] }

            let data = output.fileHandleForReading.readDataToEndOfFile()
            let path = String(decoding: data, as: UTF8.self).trimmingCharacters(
                in: .whitespacesAndNewlines)
            return path.isEmpty ? [] : [path]
        } catch {
            return []
        }
    }
}
