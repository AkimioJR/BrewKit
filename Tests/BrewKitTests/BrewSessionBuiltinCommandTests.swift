import Foundation
import Testing

@testable import BrewKit

@Test func builtinCommandArgumentsAreMapped() {
    let entries: [(BrewBuiltinCommand, [String])] = [
        (.cache(), ["--cache"]),
        (.caskroom(), ["--caskroom"]),
        (.cellar(), ["--cellar"]),
        (.env(), ["--env"]),
        (.prefix(customArgs: ["wget"]), ["--prefix", "wget"]),
        (.repository(), ["--repository"]),
        (.taps(), ["--taps"]),
        (.version(), ["--version"]),

        (.alias(), ["alias"]),
        (.analytics(), ["analytics"]),
        (.autoremove(customArgs: ["--dry-run"]), ["autoremove", "--dry-run"]),
        (.bundle(customArgs: ["dump"]), ["bundle", "dump"]),
        (.casks(), ["casks"]),
        (.cleanup(customArgs: ["--dry-run"]), ["cleanup", "--dry-run"]),
        (.commandNotFoundInit(), ["command-not-found-init"]),
        (.command(customArgs: ["install"]), ["command", "install"]),
        (.commands(customArgs: ["--quiet"]), ["commands", "--quiet"]),
        (.completions(customArgs: ["state"]), ["completions", "state"]),
        (.config(), ["config"]),
        (.deps(customArgs: ["wget"]), ["deps", "wget"]),
        (.desc(customArgs: ["wget"]), ["desc", "wget"]),
        (.developer(customArgs: ["on"]), ["developer", "on"]),
        (.docs(), ["docs"]),
        (.doctor(), ["doctor"]),
        (.execCommand(customArgs: ["echo", "ok"]), ["exec", "echo", "ok"]),
        (.fetch(customArgs: ["wget"]), ["fetch", "wget"]),
        (.formulae(), ["formulae"]),
        (.gistLogs(customArgs: ["wget"]), ["gist-logs", "wget"]),
        (.help(customArgs: ["install"]), ["help", "install"]),
        (.home(customArgs: ["wget"]), ["home", "wget"]),
        (.info(customArgs: ["wget"]), ["info", "wget"]),
        (.install(customArgs: ["wget"]), ["install", "wget"]),
        (.leaves(), ["leaves"]),
        (.link(customArgs: ["wget"]), ["link", "wget"]),
        (.list(customArgs: ["--formula"]), ["list", "--formula"]),
        (.log(customArgs: ["wget"]), ["log", "wget"]),
        (.mcpServer(), ["mcp-server"]),
        (.migrate(customArgs: ["python@3.11"]), ["migrate", "python@3.11"]),
        (.missing(), ["missing"]),
        (.nodenvSync(), ["nodenv-sync"]),
        (.options(customArgs: ["wget"]), ["options", "wget"]),
        (.outdated(customArgs: ["--json=v2"]), ["outdated", "--json=v2"]),
        (.pin(customArgs: ["wget"]), ["pin", "wget"]),
        (.postinstall(customArgs: ["wget"]), ["postinstall", "wget"]),
        (.pyenvSync(), ["pyenv-sync"]),
        (.rbenvSync(), ["rbenv-sync"]),
        (.readall(customArgs: ["--eval-all"]), ["readall", "--eval-all"]),
        (.reinstall(customArgs: ["wget"]), ["reinstall", "wget"]),
        (.search(customArgs: ["wget"]), ["search", "wget"]),
        (.services(customArgs: ["list"]), ["services", "list"]),
        (.setupRuby(), ["setup-ruby"]),
        (.shellenv(), ["shellenv"]),
        (.source(customArgs: ["wget"]), ["source", "wget"]),
        (.tab(customArgs: ["--installed-on-request", "wget"]), ["tab", "--installed-on-request", "wget"]),
        (.tapInfo(customArgs: ["--json", "homebrew/core"]), ["tap-info", "--json", "homebrew/core"]),
        (.tap(customArgs: ["homebrew/cask"]), ["tap", "homebrew/cask"]),
        (.unalias(customArgs: ["instal"]), ["unalias", "instal"]),
        (.uninstall(customArgs: ["wget"]), ["uninstall", "wget"]),
        (.unlink(customArgs: ["wget"]), ["unlink", "wget"]),
        (.unpin(customArgs: ["wget"]), ["unpin", "wget"]),
        (.untap(customArgs: ["homebrew/cask"]), ["untap", "homebrew/cask"]),
        (.updateIfNeeded(), ["update-if-needed"]),
        (.updateReset(), ["update-reset"]),
        (.update(), ["update"]),
        (.upgrade(customArgs: ["wget"]), ["upgrade", "wget"]),
        (.uses(customArgs: ["openssl@3"]), ["uses", "openssl@3"]),
        (.versionInstall(customArgs: ["1.2.3"]), ["version-install", "1.2.3"]),
        (.whichFormula(customArgs: ["wget"]), ["which-formula", "wget"]),
    ]

    for (command, expected) in entries {
        #expect(command.arguments == expected)
    }
}

@Test func runBuiltInCommandUsesMappedArguments() async throws {
    final class CallStore: @unchecked Sendable {
        private let lock = NSLock()
        private(set) var lastArguments: [String] = []

        func set(arguments: [String]) {
            lock.lock()
            lastArguments = arguments
            lock.unlock()
        }
    }

    let store = CallStore()
    let runner = MockCommandRunner { _, arguments, _, _, _ in
        store.set(arguments: arguments)
        return BrewCommandResult(stdout: "ok\n", stderr: "", exitCode: 0, duration: 0.01)
    }

    let session = try BrewSession(
        brewPath: "/bin/sh",
        environment: BrewSession.defaultEnvironment,
        timeout: 30,
        commandRunner: runner
    )

    let result = try await session.run(.tapInfo(customArgs: ["--json", "homebrew/core"]))

    #expect(store.lastArguments == ["tap-info", "--json", "homebrew/core"])
    #expect(result.stdout == "ok\n")
}
