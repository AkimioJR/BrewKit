import Foundation

/// Homebrew session actor for typed CLI integration.
/// 用于类型化 CLI 集成的 Homebrew 会话 actor。
public actor BrewSession {
    public let timeout: TimeInterval

    private let commandRunner: any BrewCommandRunning
    private let environment: [String: String]
    private let brewPathValue: String

    /// Creates a BrewSession with optional path and execution settings.
    /// 使用可选路径和执行配置创建 BrewSession。
    /// - Parameters:
    ///   - brewPath: Optional explicit brew executable path.
    ///   - environment: Environment overrides for brew commands.
    ///   - timeout: Default command timeout in seconds.
    /// - 参数:
    ///   - brewPath: 可选的 brew 可执行文件显式路径。
    ///   - environment: brew 命令的环境变量覆盖项。
    ///   - timeout: 默认命令超时时间（秒）。
    /// - Returns: A ready-to-use `BrewSession` actor instance.
    /// - 返回值: 可直接使用的 `BrewSession` actor 实例。
    public init(
        brewPath: String? = nil,
        environment: [String: String] = BrewSession.defaultEnvironment,
        timeout: TimeInterval = 30
    ) throws(BrewSessionError) {
        try self.init(
            brewPath: brewPath,
            environment: environment,
            timeout: timeout,
            commandRunner: ProcessCommandRunner()
        )
    }

    /// Creates a BrewSession with an injected command runner for tests.
    /// 使用注入命令执行器创建 BrewSession（用于测试）。
    /// - Parameters:
    ///   - brewPath: Optional explicit brew executable path.
    ///   - environment: Environment overrides for brew commands.
    ///   - timeout: Default command timeout in seconds.
    ///   - commandRunner: Injected command runner implementation.
    /// - 参数:
    ///   - brewPath: 可选的 brew 可执行文件显式路径。
    ///   - environment: brew 命令的环境变量覆盖项。
    ///   - timeout: 默认命令超时时间（秒）。
    ///   - commandRunner: 注入的命令执行器实现。
    /// - Returns: A ready-to-use `BrewSession` actor instance.
    /// - 返回值: 可直接使用的 `BrewSession` actor 实例。
    init(
        brewPath: String?,
        environment: [String: String],
        timeout: TimeInterval,
        commandRunner: any BrewCommandRunning
    ) throws(BrewSessionError) {
        self.timeout = timeout
        self.environment = environment
        self.commandRunner = commandRunner

        let resolvedPath: String
        if let brewPath {
            resolvedPath = brewPath
        } else {
            resolvedPath = try Self.autoDetectBrewPath()
        }

        guard FileManager.default.fileExists(atPath: resolvedPath),
            FileManager.default.isExecutableFile(atPath: resolvedPath)
        else {
            throw BrewSessionError.invalidBrewExecutable(path: resolvedPath)
        }

        self.brewPathValue = resolvedPath
    }

    /// Standard environment overrides for brew commands.
    /// brew 命令的标准环境覆盖项。
    public static let defaultEnvironment: [String: String] = [
        "PATH":
            "/opt/workbrew/sbin:/opt/workbrew/bin:/opt/homebrew/sbin:/opt/homebrew/bin:/usr/local/sbin:/usr/local/bin:/home/linuxbrew/.linuxbrew/bin:/usr/bin:/bin",
        "LANG": "en_US.UTF-8",
        "LC_ALL": "en_US.UTF-8",
        "HOMEBREW_NO_AUTO_UPDATE": "1",
    ]

    /// Returns the resolved brew executable path.
    /// 返回解析后的 brew 可执行文件路径。
    /// - Returns: Absolute brew executable path used by this session.
    /// - 返回值: 本会话使用的 brew 可执行文件绝对路径。
    public func brewPath() -> String {
        brewPathValue
    }

    /// Returns `brew --version` output.
    /// 返回 `brew --version` 输出。
    /// - Returns: Trimmed version output text.
    /// - 返回值: 去除首尾空白后的版本输出文本。
    public func homebrewVersion() async throws(BrewSessionError) -> String {
        let result = try await runCommand(args: ["--version"])
        return result.stdout.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    /// Returns installed formulae with version and install reason.
    /// 返回已安装 formula 的版本与安装原因。
    /// - Returns: Installed formula package list.
    /// - 返回值: 已安装 formula 软件包列表。
    public func installedFormulae() async throws(BrewSessionError) -> [BrewInstalledPackage] {
        let listResult = try await runCommand(args: ["list", "--formula", "--versions"])
        var packages = Self.parseInstalledFormulaeList(listResult.stdout)

        let infoResult = try await runCommand(args: [
            "info", "--json=v2", "--formula", "--installed",
        ])
        let reasonMap = try Self.parseInstallReasons(
            infoResult.stdout,
            command: commandString(args: ["info", "--json=v2", "--formula", "--installed"]))

        packages = packages.map { pkg in
            BrewInstalledPackage(
                name: pkg.name,
                version: pkg.version,
                kind: pkg.kind,
                installReason: reasonMap[pkg.name] ?? .unknown
            )
        }

        return packages
    }

    /// Returns installed casks with versions.
    /// 返回已安装 cask 及其版本。
    /// - Returns: Installed cask package list.
    /// - 返回值: 已安装 cask 软件包列表。
    public func installedCasks() async throws(BrewSessionError) -> [BrewInstalledPackage] {
        let listResult = try await runCommand(args: ["list", "--cask"])
        let names = Self.parseLineValues(listResult.stdout)
        if names.isEmpty { return [] }

        let args = ["info", "--cask", "--json=v2"] + names
        let infoResult = try await runCommand(args: args)
        let versionMap = try Self.parseCaskVersions(
            infoResult.stdout, command: commandString(args: args))

        return names.map {
            BrewInstalledPackage(
                name: $0, version: versionMap[$0] ?? "Unknown", kind: .cask, installReason: nil)
        }
    }

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

    /// Returns currently tapped repositories.
    /// 返回当前已 tap 的仓库。
    /// - Returns: Tapped repository list.
    /// - 返回值: 已 tap 仓库列表。
    public func taps() async throws(BrewSessionError) -> [BrewTap] {
        let result = try await runCommand(args: ["tap"])
        return Self.parseLineValues(result.stdout).map { BrewTap(name: $0) }
    }

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

    /// Installs one package.
    /// 安装一个软件包。
    /// - Parameter name: Package name to install.
    /// - 参数 name: 要安装的软件包名称。
    /// - Returns: Command execution result.
    /// - 返回值: 命令执行结果。
    public func install(_ name: String) async throws(BrewSessionError) -> BrewCommandResult {
        try await runCommand(args: ["install", name])
    }

    /// Uninstalls one package.
    /// 卸载一个软件包。
    /// - Parameter name: Package name to uninstall.
    /// - 参数 name: 要卸载的软件包名称。
    /// - Returns: Command execution result.
    /// - 返回值: 命令执行结果。
    public func uninstall(_ name: String) async throws(BrewSessionError) -> BrewCommandResult {
        try await runCommand(args: ["uninstall", name])
    }

    /// Upgrades one package.
    /// 升级一个软件包。
    /// - Parameter name: Package name to upgrade.
    /// - 参数 name: 要升级的软件包名称。
    /// - Returns: Command execution result.
    /// - 返回值: 命令执行结果。
    public func upgrade(_ name: String) async throws(BrewSessionError) -> BrewCommandResult {
        try await runCommand(args: ["upgrade", name])
    }

    /// Runs `brew update` to update local metadata.
    /// 执行 `brew update` 以更新本地元数据。
    /// - Returns: Command execution result.
    /// - 返回值: 命令执行结果。
    public func updateDatabase() async throws(BrewSessionError) -> BrewCommandResult {
        try await runCommand(args: ["update"])
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

    /// Installs one package and streams output lines.
    /// 安装一个软件包并流式输出逐行日志。
    /// - Parameter name: Package name to install.
    /// - 参数 name: 要安装的软件包名称。
    /// - Returns: Async stream of typed events carrying line text or `BrewSessionError`.
    /// - 返回值: 承载行文本或 `BrewSessionError` 的强类型异步事件流。
    public func installStream(_ name: String) -> BrewStream {
        streamCommand(args: ["install", name])
    }

    /// Upgrades one package and streams output lines.
    /// 升级一个软件包并流式输出逐行日志。
    /// - Parameter name: Package name to upgrade.
    /// - 参数 name: 要升级的软件包名称。
    /// - Returns: Async stream of typed events carrying line text or `BrewSessionError`.
    /// - 返回值: 承载行文本或 `BrewSessionError` 的强类型异步事件流。
    public func upgradeStream(_ name: String) -> BrewStream {
        streamCommand(args: ["upgrade", name])
    }

    /// Uninstalls one package and streams output lines.
    /// 卸载一个软件包并流式输出逐行日志。
    /// - Parameter name: Package name to uninstall.
    /// - 参数 name: 要卸载的软件包名称。
    /// - Returns: Async stream of typed events carrying line text or `BrewSessionError`.
    /// - 返回值: 承载行文本或 `BrewSessionError` 的强类型异步事件流。
    public func uninstallStream(_ name: String) -> BrewStream {
        streamCommand(args: ["uninstall", name])
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

    /// Executes brew command and maps non-zero exit code into `BrewSessionError`.
    /// 执行 brew 命令并将非零退出码映射为 `BrewSessionError`。
    /// - Parameter args: Brew command arguments without executable.
    /// - 参数 args: 不含可执行文件本身的 brew 命令参数。
    /// - Returns: Command execution result.
    /// - 返回值: 命令执行结果。
    private func runCommand(args: [String]) async throws(BrewSessionError) -> BrewCommandResult {
        let command = commandString(args: args)

        let result = try await commandRunner.run(
            executable: brewPathValue,
            arguments: args,
            environment: environment,
            timeout: timeout,
            stream: nil
        )

        if result.exitCode != 0 {
            throw BrewSessionError.commandFailed(
                command: command,
                exitCode: result.exitCode,
                stdout: result.stdout,
                stderr: result.stderr
            )
        }

        return result
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

    /// Creates stream-based command execution API for long-running operations.
    /// 为长耗时操作创建流式命令执行 API。
    /// - Parameter args: Brew command arguments without executable.
    /// - 参数 args: 不含可执行文件本身的 brew 命令参数。
    /// - Returns: Async stream of typed events carrying line text or `BrewSessionError`.
    /// - 返回值: 承载行文本或 `BrewSessionError` 的强类型异步事件流。
    private func streamCommand(args: [String]) -> BrewStream {
        let brewPath = brewPathValue
        let environment = self.environment
        let timeout = self.timeout
        let runner = commandRunner
        let command = commandString(args: args)

        return AsyncStream { continuation in
            Task {
                do {
                    let result = try await runner.run(
                        executable: brewPath,
                        arguments: args,
                        environment: environment,
                        timeout: timeout,
                        stream: { line in
                            continuation.yield(.success(line))
                        }
                    )

                    if result.exitCode != 0 {
                        continuation.yield(
                            .failure(
                                BrewSessionError.commandFailed(
                                    command: command,
                                    exitCode: result.exitCode,
                                    stdout: result.stdout,
                                    stderr: result.stderr
                                )
                            )
                        )
                        continuation.finish()
                        return
                    }

                    continuation.finish()
                } catch {
                    let mappedError: BrewSessionError
                    if let brewError = error as? BrewSessionError {
                        mappedError = brewError
                    } else {
                        mappedError = .commandFailed(
                            command: command,
                            exitCode: nil,
                            stdout: "",
                            stderr: error.localizedDescription
                        )
                    }
                    continuation.yield(.failure(mappedError))
                    continuation.finish()
                }
            }
        }
    }

    /// Returns a shell-like command string for diagnostics.
    /// 返回用于诊断的类 shell 命令字符串。
    /// - Parameter args: Brew command arguments without executable.
    /// - 参数 args: 不含可执行文件本身的 brew 命令参数。
    /// - Returns: Joined command string.
    /// - 返回值: 拼接后的命令字符串。
    private func commandString(args: [String]) -> String {
        ([brewPathValue] + args).joined(separator: " ")
    }
}
