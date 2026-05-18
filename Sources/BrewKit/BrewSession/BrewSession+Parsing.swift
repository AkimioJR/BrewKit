import Foundation

// MARK: - Parsing

extension BrewSession {
    /// Parses line-based command output by trimming empty lines.
    /// 通过去除空行解析按行输出。
    /// - Parameter text: Raw command output text.
    /// - 参数 text: 原始命令输出文本。
    /// - Returns: Non-empty trimmed lines.
    /// - 返回值: 去空并去首尾空白后的非空行列表。
    static func parseLineValues(_ text: String) -> [String] {
        text
            .split(whereSeparator: \.isNewline)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    /// Parses `brew list --formula --versions` output.
    /// 解析 `brew list --formula --versions` 输出。
    /// - Parameter text: Raw command output text.
    /// - 参数 text: 原始命令输出文本。
    /// - Returns: Installed formula package list.
    /// - 返回值: 已安装 formula 软件包列表。
    static func parseInstalledFormulaeList(_ text: String) -> [BrewInstalledPackage] {
        parseLineValues(text).map { line in
            let parts = line.split(whereSeparator: \.isWhitespace)
            let name = parts.first.map(String.init) ?? line
            let version = parts.dropFirst().first.map(String.init) ?? "Unknown"
            return BrewInstalledPackage(
                name: name, version: version, kind: .formula, installReason: nil)
        }
    }

    /// Parses install reason map from `brew info --json=v2 --formula --installed`.
    /// 从 `brew info --json=v2 --formula --installed` 解析安装原因映射。
    /// - Parameters:
    ///   - text: Raw command output text.
    ///   - command: Diagnostic command string.
    /// - 参数:
    ///   - text: 原始命令输出文本。
    ///   - command: 诊断用命令字符串。
    /// - Returns: Mapping from formula name to install reason.
    /// - 返回值: 从 formula 名称到安装原因的映射。
    static func parseInstallReasons(_ text: String, command: String) throws(BrewSessionError)
        -> [String: BrewInstallReason]
    {
        struct FormulaInstalled: Decodable {
            let installedOnRequest: Bool
            let installedAsDependency: Bool

            enum CodingKeys: String, CodingKey {
                case installedOnRequest = "installed_on_request"
                case installedAsDependency = "installed_as_dependency"
            }
        }

        struct FormulaItem: Decodable {
            let name: String
            let installed: [FormulaInstalled]
        }

        struct Root: Decodable {
            let formulae: [FormulaItem]
        }

        let payload = try extractJSONObjectString(from: text, command: command)

        let root: Root
        do {
            root = try JSONDecoder().decode(Root.self, from: Data(payload.utf8))
        } catch {
            throw BrewSessionError.jsonDecodeFailed(command: command, payload: payload)
        }

        var map: [String: BrewInstallReason] = [:]
        for item in root.formulae {
            let reason: BrewInstallReason
            if let installed = item.installed.first {
                if installed.installedOnRequest {
                    reason = .onRequest
                } else if installed.installedAsDependency {
                    reason = .dependency
                } else {
                    reason = .unknown
                }
            } else {
                reason = .unknown
            }
            map[item.name] = reason
        }

        return map
    }

    /// Parses cask versions from `brew info --cask --json=v2 ...`.
    /// 从 `brew info --cask --json=v2 ...` 解析 cask 版本。
    /// - Parameters:
    ///   - text: Raw command output text.
    ///   - command: Diagnostic command string.
    /// - 参数:
    ///   - text: 原始命令输出文本。
    ///   - command: 诊断用命令字符串。
    /// - Returns: Mapping from cask token to version string.
    /// - 返回值: 从 cask token 到版本字符串的映射。
    static func parseCaskVersions(_ text: String, command: String) throws(BrewSessionError)
        -> [String: String]
    {
        struct Cask: Decodable {
            let token: String
            let version: String?
        }

        struct Root: Decodable {
            let casks: [Cask]
        }

        let payload = try extractJSONObjectString(from: text, command: command)

        let root: Root
        do {
            root = try JSONDecoder().decode(Root.self, from: Data(payload.utf8))
        } catch {
            throw BrewSessionError.jsonDecodeFailed(command: command, payload: payload)
        }

        return Dictionary(
            uniqueKeysWithValues: root.casks.map { ($0.token, $0.version ?? "Unknown") })
    }

    /// Parses `brew outdated --json=v2` output while tolerating warning prefixes.
    /// 解析 `brew outdated --json=v2` 输出，并容忍前置警告。
    /// - Parameters:
    ///   - text: Raw command output text.
    ///   - command: Diagnostic command string.
    /// - 参数:
    ///   - text: 原始命令输出文本。
    ///   - command: 诊断用命令字符串。
    /// - Returns: Outdated package list.
    /// - 返回值: 可更新软件包列表。
    static func parseOutdated(_ text: String, command: String) throws(BrewSessionError)
        -> [BrewOutdatedPackage]
    {
        struct Formula: Decodable {
            let name: String
            let installedVersions: [String]
            let currentVersion: String
            let pinned: Bool

            enum CodingKeys: String, CodingKey {
                case name
                case installedVersions = "installed_versions"
                case currentVersion = "current_version"
                case pinned
            }
        }

        struct Cask: Decodable {
            let name: String
            let installedVersions: [String]
            let currentVersion: String

            enum CodingKeys: String, CodingKey {
                case name
                case installedVersions = "installed_versions"
                case currentVersion = "current_version"
            }
        }

        struct Root: Decodable {
            let formulae: [Formula]
            let casks: [Cask]
        }

        let payload = try extractJSONObjectString(from: text, command: command)

        let root: Root
        do {
            root = try JSONDecoder().decode(Root.self, from: Data(payload.utf8))
        } catch {
            throw BrewSessionError.jsonDecodeFailed(command: command, payload: payload)
        }

        let formulae = root.formulae
            .filter { !$0.pinned }
            .map {
                BrewOutdatedPackage(
                    name: $0.name,
                    installedVersions: $0.installedVersions,
                    currentVersion: $0.currentVersion,
                    kind: .formula,
                    pinned: $0.pinned
                )
            }

        let casks = root.casks.map {
            BrewOutdatedPackage(
                name: $0.name,
                installedVersions: $0.installedVersions,
                currentVersion: $0.currentVersion,
                kind: .cask,
                pinned: false
            )
        }

        return formulae + casks
    }

    /// Parses summarized info from `brew info --json=v2 ...`.
    /// 从 `brew info --json=v2 ...` 解析摘要信息。
    /// - Parameters:
    ///   - text: Raw command output text.
    ///   - command: Diagnostic command string.
    /// - 参数:
    ///   - text: 原始命令输出文本。
    ///   - command: 诊断用命令字符串。
    /// - Returns: Parsed strongly typed package info object.
    /// - 返回值: 解析后的强类型软件包信息对象。
    static func parseInfo(_ text: String, command: String) throws(BrewSessionError)
        -> BrewPackageInfo
    {
        struct FormulaInstalledEntry: Decodable {
            let version: String?
        }

        struct FormulaInfo: Decodable {
            let name: String
            let fullName: String?
            let desc: String?
            let homepage: String?
            let tap: String?
            let aliases: [String]
            let oldnames: [String]
            let versions: Versions?
            let installed: [FormulaInstalledEntry]?
            let pinned: Bool?
            let outdated: Bool?

            struct Versions: Decodable {
                let stable: String?
            }

            enum CodingKeys: String, CodingKey {
                case name
                case fullName = "full_name"
                case desc
                case homepage
                case tap
                case aliases
                case oldnames
                case versions
                case installed
                case pinned
                case outdated
            }
        }

        struct CaskInfo: Decodable {
            let token: String
            let fullToken: String?
            let desc: String?
            let homepage: String?
            let tap: String?
            let version: String?
            let installed: String?
            let outdated: Bool?
            let autoUpdates: Bool?

            enum CodingKeys: String, CodingKey {
                case token
                case fullToken = "full_token"
                case desc
                case homepage
                case tap
                case version
                case installed
                case outdated
                case autoUpdates = "auto_updates"
            }
        }

        struct Root: Decodable {
            let formulae: [FormulaInfo]
            let casks: [CaskInfo]
        }

        let payload = try extractJSONObjectString(from: text, command: command)

        let root: Root
        do {
            root = try JSONDecoder().decode(Root.self, from: Data(payload.utf8))
        } catch {
            throw BrewSessionError.jsonDecodeFailed(command: command, payload: payload)
        }

        if let formula = root.formulae.first {
            return BrewPackageInfo(
                kind: .formula,
                name: formula.name,
                fullName: formula.fullName,
                description: formula.desc,
                homepage: formula.homepage,
                tap: formula.tap,
                version: formula.versions?.stable,
                installedVersions: formula.installed?.compactMap(\.version) ?? [],
                aliases: formula.aliases,
                oldNames: formula.oldnames,
                pinned: formula.pinned,
                outdated: formula.outdated,
                autoUpdates: nil
            )
        }

        if let cask = root.casks.first {
            return BrewPackageInfo(
                kind: .cask,
                name: cask.token,
                fullName: cask.fullToken,
                description: cask.desc,
                homepage: cask.homepage,
                tap: cask.tap,
                version: cask.version,
                installedVersions: cask.installed.map { [$0] } ?? [],
                aliases: [],
                oldNames: [],
                pinned: nil,
                outdated: cask.outdated,
                autoUpdates: cask.autoUpdates
            )
        }

        throw BrewSessionError.jsonDecodeFailed(command: command, payload: payload)
    }

    /// Extracts JSON object or array payload from mixed output.
    /// 从混合输出中提取 JSON 对象或数组载荷。
    /// - Parameters:
    ///   - text: Raw command output text.
    ///   - command: Diagnostic command string.
    /// - 参数:
    ///   - text: 原始命令输出文本。
    ///   - command: 诊断用命令字符串。
    /// - Returns: Extracted JSON payload string.
    /// - 返回值: 提取出的 JSON 载荷字符串。
    static func extractJSONObjectString(from text: String, command: String) throws(BrewSessionError)
        -> String
    {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            throw BrewSessionError.jsonDecodeFailed(command: command, payload: text)
        }

        let firstObject = trimmed.firstIndex(of: "{")
        let firstArray = trimmed.firstIndex(of: "[")

        let start: String.Index
        switch (firstObject, firstArray) {
        case (let o?, let a?):
            start = o < a ? o : a
        case (let o?, nil):
            start = o
        case (nil, let a?):
            start = a
        case (nil, nil):
            throw BrewSessionError.jsonDecodeFailed(command: command, payload: text)
        }

        let candidate = String(trimmed[start...])

        if let objStart = candidate.firstIndex(of: "{"),
            let objEnd = candidate.lastIndex(of: "}")
        {
            let objectPayload = String(candidate[objStart...objEnd])
            if isValidJSON(objectPayload) {
                return objectPayload
            }
        }

        if let arrStart = candidate.firstIndex(of: "["),
            let arrEnd = candidate.lastIndex(of: "]")
        {
            let arrayPayload = String(candidate[arrStart...arrEnd])
            if isValidJSON(arrayPayload) {
                return arrayPayload
            }
        }

        throw BrewSessionError.jsonDecodeFailed(command: command, payload: text)
    }

    /// Validates whether payload text is syntactically valid JSON.
    /// 校验载荷文本是否为语法有效的 JSON。
    /// - Parameter payload: Candidate JSON payload.
    /// - 参数 payload: 待校验的 JSON 载荷。
    /// - Returns: `true` when payload can be decoded by `JSONSerialization`.
    /// - 返回值: 当 `JSONSerialization` 可解码时返回 `true`。
    static func isValidJSON(_ payload: String) -> Bool {
        guard let data = payload.data(using: .utf8) else { return false }
        return (try? JSONSerialization.jsonObject(with: data)) != nil
    }
}
