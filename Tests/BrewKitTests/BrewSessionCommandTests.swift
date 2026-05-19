import Foundation
import Testing

@testable import BrewKit

@Test func commandArgumentBuilding() async throws {
    let session = try BrewSession(brewPath: "/bin/sh")

    let outdatedArgs = await session.buildOutdatedArguments(
        mode: .greedyAutoUpdates, customArgs: ["--verbose"])
    let infoFormulaArgs = await session.buildInfoArguments(name: "wget", kindHint: .formula)
    let infoCaskArgs = await session.buildInfoArguments(name: "iterm2", kindHint: .cask)

    #expect(outdatedArgs == ["outdated", "--json=v2", "--greedy-auto-updates", "--verbose"])
    #expect(infoFormulaArgs == ["info", "--json=v2", "--formula", "wget"])
    #expect(infoCaskArgs == ["info", "--json=v2", "--cask", "iterm2"])
}

@Test func commandFailureIsMappedToTypedError() async throws {
    let runner = MockCommandRunner { _, _, _, _, _ in
        BrewCommandResult(stdout: "", stderr: "boom", exitCode: 1, duration: 0.01)
    }

    let session = try BrewSession(
        brewPath: "/bin/sh",
        environment: BrewSession.defaultEnvironment,
        timeout: 30,
        commandRunner: runner
    )

    await #expect(throws: BrewSessionError.self) {
        _ = try await session.homebrewVersion()
    }
}

@Test func timeoutErrorIsPropagated() async throws {
    let runner = MockCommandRunner {
        (
            _: String, _: [String], _: [String: String], timeout: TimeInterval,
            _: (@Sendable (String) -> Void)?
        ) async throws(BrewSessionError) -> BrewCommandResult in
        throw BrewSessionError.commandTimedOut(command: "brew update", timeout: timeout)
    }

    let session = try BrewSession(
        brewPath: "/bin/sh",
        environment: BrewSession.defaultEnvironment,
        timeout: 30,
        commandRunner: runner
    )

    await #expect(throws: BrewSessionError.self) {
        _ = try await session.updateDatabase()
    }
}

@Test func streamAPIYieldsLinesAndFinishes() async throws {
    let runner = MockCommandRunner { _, _, _, _, stream in
        stream?("line-1")
        stream?("line-2")
        return BrewCommandResult(stdout: "line-1\nline-2\n", stderr: "", exitCode: 0, duration: 0.1)
    }

    let session = try BrewSession(
        brewPath: "/bin/sh",
        environment: BrewSession.defaultEnvironment,
        timeout: 30,
        commandRunner: runner
    )

    var lines: [String] = []
    var failures: [BrewSessionError] = []
    for await event in await session.installStream("demo") {
        switch event {
        case .success(let line):
            lines.append(line)
        case .failure(let error):
            failures.append(error)
        }
    }

    #expect(lines == ["line-1", "line-2"])
    #expect(failures.isEmpty)
}
