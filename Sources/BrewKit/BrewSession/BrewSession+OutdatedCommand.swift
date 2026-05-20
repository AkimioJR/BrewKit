import Foundation

// MARK: - brew outdated

extension BrewSession {
    /// Returns outdated package list from `brew outdated --json=v2`.
    /// 返回来自 `brew outdated --json=v2` 的可更新软件包列表。
    /// - Parameters:
    ///   - mode: Outdated mode flags.
    ///   - customArgs: Additional custom command arguments.
    /// - 参数:
    ///   - mode: outdated 模式参数。
    ///   - customArgs: 额外自定义命令参数。
    /// - Returns: Outdated package list.
    /// - 返回值: 可更新软件包列表。
    public func outdated(mode: BrewOutdatedMode = .none, customArgs: [String] = [])
        async throws(BrewSessionError)
        -> [BrewOutdatedPackage]
    {
        let args = buildOutdatedArguments(mode: mode, customArgs: customArgs)
        let result = try await runCommand(args: args)
        return try Self.parseOutdated(result.stdout, command: commandString(args: args))
    }

    /// Builds arguments for `brew outdated` based on mode and custom flags.
    /// 根据模式和自定义选项构建 `brew outdated` 参数。
    /// - Parameters:
    ///   - mode: Outdated mode flags.
    ///   - customArgs: Additional custom command arguments.
    /// - 参数:
    ///   - mode: outdated 模式参数。
    ///   - customArgs: 额外自定义命令参数。
    /// - Returns: Prepared argument array.
    /// - 返回值: 准备好的参数数组。
    func buildOutdatedArguments(mode: BrewOutdatedMode = .none, customArgs: [String] = [])
        -> [String]
    {
        var args = ["outdated", "--json=v2"]
        switch mode {
        case .none:
            break
        case .greedy:
            args.append("--greedy")
        case .greedyAutoUpdates:
            args.append("--greedy-auto-updates")
        }
        args.append(contentsOf: customArgs)
        return args
    }
}
