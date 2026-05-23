import Foundation
import Testing

@testable import BrewKit

private final class PathCommandCallStore: @unchecked Sendable {
    private let lock = NSLock()
    private(set) var lastArguments: [String] = []

    func set(arguments: [String]) {
        lock.lock()
        lastArguments = arguments
        lock.unlock()
    }
}

@Test func cachePathUsesMappedArgumentsAndTrimsOutput() async throws {
    let store = PathCommandCallStore()
    let runner = MockCommandRunner { _, arguments, _, _, _ in
        store.set(arguments: arguments)
        return BrewCommandResult(
            stdout: "/Users/example/Library/Caches/Homebrew/downloads/wget.bottle.tar.gz\n",
            stderr: "",
            exitCode: 0,
            duration: 0.01
        )
    }

    let session = try BrewSession(
        brewPath: "/bin/sh",
        environment: BrewSession.defaultEnvironment,
        timeout: 30,
        commandRunner: runner
    )

    let path = try await session.cachePath(for: "wget", kindHint: .formula)

    #expect(store.lastArguments == ["--cache", "--formula", "wget"])
    #expect(path == "/Users/example/Library/Caches/Homebrew/downloads/wget.bottle.tar.gz")
}

@Test func cachePathArgumentBuilderSupportsKindHintAndCustomArguments() async throws {
    let session = try BrewSession(brewPath: "/bin/sh")

    let formulaArgs = await session.buildCachePathArguments(
        for: "wget",
        kindHint: .formula,
        customArgs: ["--force-bottle"]
    )
    let caskArgs = await session.buildCachePathArguments(for: "firefox", kindHint: .cask)

    #expect(formulaArgs == ["--cache", "--formula", "--force-bottle", "wget"])
    #expect(caskArgs == ["--cache", "--cask", "firefox"])
}

@Test func cellarPathUsesMappedArgumentsAndTrimsOutput() async throws {
    let store = PathCommandCallStore()
    let runner = MockCommandRunner { _, arguments, _, _, _ in
        store.set(arguments: arguments)
        return BrewCommandResult(
            stdout: "/opt/homebrew/Cellar/wget\n",
            stderr: "",
            exitCode: 0,
            duration: 0.01
        )
    }

    let session = try BrewSession(
        brewPath: "/bin/sh",
        environment: BrewSession.defaultEnvironment,
        timeout: 30,
        commandRunner: runner
    )

    let path = try await session.cellarPath(forFormula: "wget")

    #expect(store.lastArguments == ["--cellar", "wget"])
    #expect(path == "/opt/homebrew/Cellar/wget")
}

@Test func prefixPathUsesMappedArgumentsAndTrimsOutput() async throws {
    let store = PathCommandCallStore()
    let runner = MockCommandRunner { _, arguments, _, _, _ in
        store.set(arguments: arguments)
        return BrewCommandResult(
            stdout: "/opt/homebrew/opt/wget\n",
            stderr: "",
            exitCode: 0,
            duration: 0.01
        )
    }

    let session = try BrewSession(
        brewPath: "/bin/sh",
        environment: BrewSession.defaultEnvironment,
        timeout: 30,
        commandRunner: runner
    )

    let path = try await session.prefixPath(forFormula: "wget")

    #expect(store.lastArguments == ["--prefix", "wget"])
    #expect(path == "/opt/homebrew/opt/wget")
}
