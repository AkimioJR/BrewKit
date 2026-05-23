import Foundation

// MARK: - brew path commands

extension BrewSession {
    /// Returns the cache file or directory path for one formula or cask.
    /// 返回指定 formula 或 cask 的缓存文件或目录路径。
    /// - Parameters:
    ///   - name: Formula or cask name to query.
    ///   - kindHint: Optional package kind hint used to add `--formula` or `--cask`.
    ///   - customArgs: Additional arguments accepted by `brew --cache`.
    /// - 参数:
    ///   - name: 要查询的 formula 或 cask 名称。
    ///   - kindHint: 可选的软件包类型提示，用于添加 `--formula` 或 `--cask`。
    ///   - customArgs: `brew --cache` 接受的额外参数。
    /// - Returns: Trimmed cache path output.
    /// - 返回值: 去除首尾空白后的缓存路径输出。
    public func cachePath(
        for name: String,
        kindHint: BrewPackageKind? = nil,
        customArgs: [String] = []
    ) async throws(BrewSessionError) -> String {
        let args = buildCachePathArguments(for: name, kindHint: kindHint, customArgs: customArgs)
        let result = try await runCommand(args: args)
        return result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Builds arguments for `brew --cache` with an optional package kind hint.
    /// 使用可选软件包类型提示构建 `brew --cache` 参数。
    /// - Parameters:
    ///   - name: Formula or cask name to query.
    ///   - kindHint: Optional package kind hint.
    ///   - customArgs: Additional arguments accepted by `brew --cache`.
    /// - 参数:
    ///   - name: 要查询的 formula 或 cask 名称。
    ///   - kindHint: 可选的软件包类型提示。
    ///   - customArgs: `brew --cache` 接受的额外参数。
    /// - Returns: Prepared argument array.
    /// - 返回值: 准备好的参数数组。
    func buildCachePathArguments(
        for name: String,
        kindHint: BrewPackageKind? = nil,
        customArgs: [String] = []
    ) -> [String] {
        var args = ["--cache"]
        if let kindHint {
            switch kindHint {
            case .formula:
                args.append("--formula")
            case .cask:
                args.append("--cask")
            }
        }
        args.append(contentsOf: customArgs)
        args.append(name)
        return args
    }

    /// Returns the Cellar path where one formula is or would be installed.
    /// 返回指定 formula 已安装或将安装到的 Cellar 路径。
    /// - Parameter formula: Formula name to query.
    /// - 参数 formula: 要查询的 formula 名称。
    /// - Returns: Trimmed Cellar path output.
    /// - 返回值: 去除首尾空白后的 Cellar 路径输出。
    public func cellarPath(forFormula formula: String) async throws(BrewSessionError) -> String {
        let result = try await runCommand(args: ["--cellar", formula])
        return result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Returns the installation prefix path for one formula.
    /// 返回指定 formula 的安装前缀路径。
    /// - Parameter formula: Formula name to query.
    /// - 参数 formula: 要查询的 formula 名称。
    /// - Returns: Trimmed prefix path output.
    /// - 返回值: 去除首尾空白后的前缀路径输出。
    public func prefixPath(forFormula formula: String) async throws(BrewSessionError) -> String {
        let result = try await runCommand(args: ["--prefix", formula])
        return result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
