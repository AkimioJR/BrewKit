import Foundation

/// Built-in Homebrew command abstraction.
/// Homebrew 内置命令抽象。
public enum BrewBuiltinCommand: Sendable, Equatable {
    case cache(customArgs: [String] = [])
    case caskroom(customArgs: [String] = [])
    case cellar(customArgs: [String] = [])
    case env(customArgs: [String] = [])
    case prefix(customArgs: [String] = [])
    case repository(customArgs: [String] = [])
    case taps(customArgs: [String] = [])
    case version(customArgs: [String] = [])

    case alias(customArgs: [String] = [])
    case analytics(customArgs: [String] = [])
    case autoremove(customArgs: [String] = [])
    case bundle(customArgs: [String] = [])
    case casks(customArgs: [String] = [])
    case cleanup(customArgs: [String] = [])
    case commandNotFoundInit(customArgs: [String] = [])
    case command(customArgs: [String] = [])
    case commands(customArgs: [String] = [])
    case completions(customArgs: [String] = [])
    case config(customArgs: [String] = [])
    case deps(customArgs: [String] = [])
    case desc(customArgs: [String] = [])
    case developer(customArgs: [String] = [])
    case docs(customArgs: [String] = [])
    case doctor(customArgs: [String] = [])
    case execCommand(customArgs: [String] = [])
    case fetch(customArgs: [String] = [])
    case formulae(customArgs: [String] = [])
    case gistLogs(customArgs: [String] = [])
    case help(customArgs: [String] = [])
    case home(customArgs: [String] = [])
    case info(customArgs: [String] = [])
    case install(customArgs: [String] = [])
    case leaves(customArgs: [String] = [])
    case link(customArgs: [String] = [])
    case list(customArgs: [String] = [])
    case log(customArgs: [String] = [])
    case mcpServer(customArgs: [String] = [])
    case migrate(customArgs: [String] = [])
    case missing(customArgs: [String] = [])
    case nodenvSync(customArgs: [String] = [])
    case options(customArgs: [String] = [])
    case outdated(customArgs: [String] = [])
    case pin(customArgs: [String] = [])
    case postinstall(customArgs: [String] = [])
    case pyenvSync(customArgs: [String] = [])
    case rbenvSync(customArgs: [String] = [])
    case readall(customArgs: [String] = [])
    case reinstall(customArgs: [String] = [])
    case search(customArgs: [String] = [])
    case services(customArgs: [String] = [])
    case setupRuby(customArgs: [String] = [])
    case shellenv(customArgs: [String] = [])
    case source(customArgs: [String] = [])
    case tab(customArgs: [String] = [])
    case tapInfo(customArgs: [String] = [])
    case tap(customArgs: [String] = [])
    case unalias(customArgs: [String] = [])
    case uninstall(customArgs: [String] = [])
    case unlink(customArgs: [String] = [])
    case unpin(customArgs: [String] = [])
    case untap(customArgs: [String] = [])
    case updateIfNeeded(customArgs: [String] = [])
    case updateReset(customArgs: [String] = [])
    case update(customArgs: [String] = [])
    case upgrade(customArgs: [String] = [])
    case uses(customArgs: [String] = [])
    case versionInstall(customArgs: [String] = [])
    case whichFormula(customArgs: [String] = [])

    /// Returns brew argument array for the command.
    /// 返回该命令的 brew 参数数组。
    public var arguments: [String] {
        switch self {
        case .cache(let customArgs): ["--cache"] + customArgs
        case .caskroom(let customArgs): ["--caskroom"] + customArgs
        case .cellar(let customArgs): ["--cellar"] + customArgs
        case .env(let customArgs): ["--env"] + customArgs
        case .prefix(let customArgs): ["--prefix"] + customArgs
        case .repository(let customArgs): ["--repository"] + customArgs
        case .taps(let customArgs): ["--taps"] + customArgs
        case .version(let customArgs): ["--version"] + customArgs

        case .alias(let customArgs): ["alias"] + customArgs
        case .analytics(let customArgs): ["analytics"] + customArgs
        case .autoremove(let customArgs): ["autoremove"] + customArgs
        case .bundle(let customArgs): ["bundle"] + customArgs
        case .casks(let customArgs): ["casks"] + customArgs
        case .cleanup(let customArgs): ["cleanup"] + customArgs
        case .commandNotFoundInit(let customArgs): ["command-not-found-init"] + customArgs
        case .command(let customArgs): ["command"] + customArgs
        case .commands(let customArgs): ["commands"] + customArgs
        case .completions(let customArgs): ["completions"] + customArgs
        case .config(let customArgs): ["config"] + customArgs
        case .deps(let customArgs): ["deps"] + customArgs
        case .desc(let customArgs): ["desc"] + customArgs
        case .developer(let customArgs): ["developer"] + customArgs
        case .docs(let customArgs): ["docs"] + customArgs
        case .doctor(let customArgs): ["doctor"] + customArgs
        case .execCommand(let customArgs): ["exec"] + customArgs
        case .fetch(let customArgs): ["fetch"] + customArgs
        case .formulae(let customArgs): ["formulae"] + customArgs
        case .gistLogs(let customArgs): ["gist-logs"] + customArgs
        case .help(let customArgs): ["help"] + customArgs
        case .home(let customArgs): ["home"] + customArgs
        case .info(let customArgs): ["info"] + customArgs
        case .install(let customArgs): ["install"] + customArgs
        case .leaves(let customArgs): ["leaves"] + customArgs
        case .link(let customArgs): ["link"] + customArgs
        case .list(let customArgs): ["list"] + customArgs
        case .log(let customArgs): ["log"] + customArgs
        case .mcpServer(let customArgs): ["mcp-server"] + customArgs
        case .migrate(let customArgs): ["migrate"] + customArgs
        case .missing(let customArgs): ["missing"] + customArgs
        case .nodenvSync(let customArgs): ["nodenv-sync"] + customArgs
        case .options(let customArgs): ["options"] + customArgs
        case .outdated(let customArgs): ["outdated"] + customArgs
        case .pin(let customArgs): ["pin"] + customArgs
        case .postinstall(let customArgs): ["postinstall"] + customArgs
        case .pyenvSync(let customArgs): ["pyenv-sync"] + customArgs
        case .rbenvSync(let customArgs): ["rbenv-sync"] + customArgs
        case .readall(let customArgs): ["readall"] + customArgs
        case .reinstall(let customArgs): ["reinstall"] + customArgs
        case .search(let customArgs): ["search"] + customArgs
        case .services(let customArgs): ["services"] + customArgs
        case .setupRuby(let customArgs): ["setup-ruby"] + customArgs
        case .shellenv(let customArgs): ["shellenv"] + customArgs
        case .source(let customArgs): ["source"] + customArgs
        case .tab(let customArgs): ["tab"] + customArgs
        case .tapInfo(let customArgs): ["tap-info"] + customArgs
        case .tap(let customArgs): ["tap"] + customArgs
        case .unalias(let customArgs): ["unalias"] + customArgs
        case .uninstall(let customArgs): ["uninstall"] + customArgs
        case .unlink(let customArgs): ["unlink"] + customArgs
        case .unpin(let customArgs): ["unpin"] + customArgs
        case .untap(let customArgs): ["untap"] + customArgs
        case .updateIfNeeded(let customArgs): ["update-if-needed"] + customArgs
        case .updateReset(let customArgs): ["update-reset"] + customArgs
        case .update(let customArgs): ["update"] + customArgs
        case .upgrade(let customArgs): ["upgrade"] + customArgs
        case .uses(let customArgs): ["uses"] + customArgs
        case .versionInstall(let customArgs): ["version-install"] + customArgs
        case .whichFormula(let customArgs): ["which-formula"] + customArgs
        }
    }
}
