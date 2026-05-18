import Foundation
import Testing

@testable import BrewKit

/// Mock runner for deterministic BrewSession tests. 用于 BrewSession 确定性测试的模拟执行器。
private struct MockCommandRunner: BrewCommandRunning {
    let handler:
        @Sendable (
            _ executable: String, _ arguments: [String], _ environment: [String: String],
            _ timeout: TimeInterval, _ stream: (@Sendable (String) -> Void)?
        ) async throws(BrewSessionError) -> BrewCommandResult

    func run(
        executable: String,
        arguments: [String],
        environment: [String: String],
        timeout: TimeInterval,
        stream: (@Sendable (String) -> Void)?
    ) async throws(BrewSessionError) -> BrewCommandResult {
        try await handler(executable, arguments, environment, timeout, stream)
    }
}

@Test func brewSessionErrorDescriptions() {
    let notFound = BrewSessionError.brewNotFound(candidates: ["/opt/homebrew/bin/brew"])
    let timeout = BrewSessionError.commandTimedOut(command: "brew update", timeout: 30)

    #expect(notFound.errorDescription?.contains("not found") == true)
    #expect(timeout.errorDescription?.contains("timed out") == true)
}

@Test func outdatedParsingSkipsPinnedFormulaAndKeepsCasks() throws {
    let text = """
        Warning: cask.jws.json: update failed, falling back to cached version.
        {
          "formulae": [
            {
              "name": "abseil",
              "installed_versions": ["20260107.0"],
              "current_version": "20260107.1",
              "pinned": false,
              "pinned_version": null
            },
            {
              "name": "pinned-formula",
              "installed_versions": ["1.0.0"],
              "current_version": "1.1.0",
              "pinned": true,
              "pinned_version": "1.0.0"
            }
          ],
          "casks": [
            {
              "name": "airbattery",
              "installed_versions": ["1.6.0"],
              "current_version": "1.6.2"
            }
          ]
        }
        """

    let packages = try BrewSession.parseOutdated(text, command: "brew outdated --json=v2")

    #expect(packages.count == 2)
    #expect(packages.contains(where: { $0.name == "abseil" && $0.kind == .formula }))
    #expect(packages.contains(where: { $0.name == "airbattery" && $0.kind == .cask }))
    #expect(packages.contains(where: { $0.name == "pinned-formula" }) == false)
}

@Test func infoParsingReturnsStrongTypedModel() throws {
    let text = """
        {
          "formulae": [],
          "casks": [
            {
              "token": "airbattery",
              "full_token": "lihaoyun6/tap/airbattery",
              "desc": "Get the battery level",
              "homepage": "https://github.com/lihaoyun6/AirBattery",
              "version": "1.6.2",
              "installed": "1.6.0"
            }
          ]
        }
        """

    let summary = try BrewSession.parseInfo(text, command: "brew info --json=v2 airbattery")

    #expect(summary.name == "airbattery")
    #expect(summary.kind == .cask)
    #expect(summary.version == "1.6.2")
    #expect(summary.fullName == "lihaoyun6/tap/airbattery")
    #expect(summary.installedVersions == ["1.6.0"])
}

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
