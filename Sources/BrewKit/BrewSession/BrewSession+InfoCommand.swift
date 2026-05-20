import Foundation

// MARK: - brew info

extension BrewSession {
    /// Returns strongly typed package info.
    /// 返回强类型软件包信息。
    /// - Parameters:
    ///   - name: Package name to query.
    ///   - kindHint: Optional package kind hint to narrow command behavior.
    /// - 参数:
    ///   - name: 要查询的软件包名称。
    ///   - kindHint: 可选的软件包类型提示，用于缩小命令行为。
    /// - Returns: Parsed strongly typed package information.
    /// - 返回值: 解析后的强类型软件包信息。
    public func info(name: String, kindHint: BrewPackageKind? = nil) async throws(BrewSessionError)
        -> BrewPackageInfo
    {
        let args = buildInfoArguments(name: name, kindHint: kindHint)
        let result = try await runCommand(args: args)
        return try Self.parseInfo(result.stdout, command: commandString(args: args))
    }

    /// Builds arguments for `brew info` with optional kind hints.
    /// 使用可选类型提示构建 `brew info` 参数。
    /// - Parameters:
    ///   - name: Package name to query.
    ///   - kindHint: Optional package kind hint.
    /// - 参数:
    ///   - name: 要查询的软件包名称。
    ///   - kindHint: 可选的软件包类型提示。
    /// - Returns: Prepared argument array.
    /// - 返回值: 准备好的参数数组。
    func buildInfoArguments(name: String, kindHint: BrewPackageKind? = nil) -> [String] {
        var args = ["info", "--json=v2"]
        if let kindHint {
            switch kindHint {
            case .formula:
                args.append("--formula")
            case .cask:
                args.append("--cask")
            }
        }
        args.append(name)
        return args
    }

    /// Builds arguments for `brew info` with multiple package names.
    /// 使用多个软件包名称构建 `brew info` 参数。
    /// - Parameters:
    ///   - names: Package names to query.
    ///   - kind: Optional package kind hint.
    /// - 参数:
    ///   - names: 要查询的软件包名称列表。
    ///   - kind: 可选的软件包类型提示。
    /// - Returns: Prepared argument array.
    /// - 返回值: 准备好的参数数组。
    func buildInfoArguments(names: [String], kind: BrewPackageKind? = nil) -> [String] {
        var args = ["info", "--json=v2"]
        if let kind {
            switch kind {
            case .formula:
                args.append("--formula")
            case .cask:
                args.append("--cask")
            }
        }
        args.append(contentsOf: names)
        return args
    }
}
