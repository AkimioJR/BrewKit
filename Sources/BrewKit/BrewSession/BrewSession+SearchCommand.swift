import Foundation

// MARK: - brew search

extension BrewSession {
    /// Searches packages and returns grouped structured info.
    /// 搜索软件包并返回分组的结构化信息。
    /// - Parameters:
    ///   - query: Search keyword or regex text passed to `brew search`.
    ///   - kind: Optional kind filter. `nil` means searching both formula and cask.
    /// - 参数:
    ///   - query: 传递给 `brew search` 的关键字或正则文本。
    ///   - kind: 可选类型过滤。`nil` 表示同时搜索 formula 与 cask。
    /// - Returns: Grouped search result containing formula and cask info arrays.
    /// - 返回值: 同时包含 formula 与 cask 信息数组的分组搜索结果。
    public func search(_ query: String, for kind: BrewPackageKind? = nil)
        async throws(BrewSessionError) -> BrewSearchResult
    {
        switch kind {
        case .formula:
            return BrewSearchResult(
                formulae: try await search(query),
                casks: []
            )
        case .cask:
            return BrewSearchResult(
                formulae: [],
                casks: try await search(query)
            )
        case nil:
            return BrewSearchResult(
                formulae: try await search(query),
                casks: try await search(query)
            )
        }
    }

    /// Searches formulae and returns formula info array.
    /// 搜索 formula 并返回 formula 信息数组。
    /// - Parameters:
    ///   - query: Search keyword or regex text passed to `brew search --formula`.
    ///   - _: Marker type for formula overload resolution.
    /// - 参数:
    ///   - query: 传递给 `brew search --formula` 的关键字或正则文本。
    ///   - _: 用于 formula 重载分发的标记类型。
    /// - Returns: Matched formula info array.
    /// - 返回值: 命中的 formula 信息数组。
    public func search(_ query: String) async throws(BrewSessionError) -> [BrewFormulaInfo] {
        let names = try await searchNames(query, kind: .formula)
        if names.isEmpty { return [] }
        let payload = try await fetchInfoPayload(names: names, kind: .formula)
        return payload.formulae
    }

    /// Searches casks and returns cask info array.
    /// 搜索 cask 并返回 cask 信息数组。
    /// - Parameters:
    ///   - query: Search keyword or regex text passed to `brew search --cask`.
    ///   - _: Marker type for cask overload resolution.
    /// - 参数:
    ///   - query: 传递给 `brew search --cask` 的关键字或正则文本。
    ///   - _: 用于 cask 重载分发的标记类型。
    /// - Returns: Matched cask info array.
    /// - 返回值: 命中的 cask 信息数组。
    public func search(_ query: String) async throws(BrewSessionError) -> [BrewCaskInfo] {
        let names = try await searchNames(query, kind: .cask)
        if names.isEmpty { return [] }
        let payload = try await fetchInfoPayload(names: names, kind: .cask)
        return payload.casks
    }

    /// Builds arguments for `brew search` for a specific kind.
    /// 为指定类型构建 `brew search` 参数。
    /// - Parameters:
    ///   - query: Search keyword or regex text.
    ///   - kind: Package kind to search.
    /// - 参数:
    ///   - query: 搜索关键字或正则文本。
    ///   - kind: 需要搜索的软件包类型。
    /// - Returns: Prepared argument array.
    /// - 返回值: 准备好的参数数组。
    func buildSearchArguments(query: String, kind: BrewPackageKind) -> [String] {
        var args = ["search"]
        switch kind {
        case .formula:
            args.append("--formula")
        case .cask:
            args.append("--cask")
        }
        args.append(query)
        return args
    }

    /// Searches package names by kind.
    /// 按类型搜索软件包名称。
    /// - Parameters:
    ///   - query: Search keyword or regex text.
    ///   - kind: Package kind to search.
    /// - 参数:
    ///   - query: 搜索关键字或正则文本。
    ///   - kind: 需要搜索的软件包类型。
    /// - Returns: Matched package names.
    /// - 返回值: 命中的软件包名称列表。
    private func searchNames(_ query: String, kind: BrewPackageKind) async throws(BrewSessionError)
        -> [String]
    {
        let args = buildSearchArguments(query: query, kind: kind)
        let result = try await runCommand(args: args)
        return Self.parseSearchNames(result.stdout)
    }

    /// Fetches info payload for multiple package names with chunked requests.
    /// 通过分块请求获取多个软件包名称的信息载荷。
    /// - Parameters:
    ///   - names: Package names to fetch.
    ///   - kind: Package kind to constrain info output.
    /// - 参数:
    ///   - names: 需要获取信息的软件包名称列表。
    ///   - kind: 用于约束 info 输出的软件包类型。
    /// - Returns: Merged info payload containing all matched entries.
    /// - 返回值: 合并后的信息载荷，包含所有命中条目。
    private func fetchInfoPayload(names: [String], kind: BrewPackageKind)
        async throws(BrewSessionError) -> BrewInfoPayload
    {
        guard !names.isEmpty else {
            return BrewInfoPayload(formulae: [], casks: [])
        }

        let chunkSize = 128
        var formulae: [BrewFormulaInfo] = []
        var casks: [BrewCaskInfo] = []

        var index = 0
        while index < names.count {
            let end = min(index + chunkSize, names.count)
            let chunk = Array(names[index..<end])
            let args = buildInfoArguments(names: chunk, kind: kind)
            let result = try await runCommand(args: args)
            let payload = try Self.parseInfoPayload(
                result.stdout, command: commandString(args: args))
            formulae.append(contentsOf: payload.formulae)
            casks.append(contentsOf: payload.casks)
            index = end
        }

        return BrewInfoPayload(formulae: formulae, casks: casks)
    }
}
