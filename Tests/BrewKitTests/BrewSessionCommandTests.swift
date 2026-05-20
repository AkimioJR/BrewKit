import Foundation
import Testing

@testable import BrewKit

@Test func commandArgumentBuilding() async throws {
    let session = try BrewSession(brewPath: "/bin/sh")

    let outdatedArgs = await session.buildOutdatedArguments(
        mode: .greedyAutoUpdates, customArgs: ["--verbose"])
    let infoFormulaArgs = await session.buildInfoArguments(name: "wget", kindHint: .formula)
    let infoCaskArgs = await session.buildInfoArguments(name: "iterm2", kindHint: .cask)
    let searchFormulaArgs = await session.buildSearchArguments(query: "wget", kind: .formula)
    let searchCaskArgs = await session.buildSearchArguments(query: "iterm", kind: .cask)
    let multiInfoArgs = await session.buildInfoArguments(
        names: ["wget", "curl"], kind: .formula)

    #expect(outdatedArgs == ["outdated", "--json=v2", "--greedy-auto-updates", "--verbose"])
    #expect(infoFormulaArgs == ["info", "--json=v2", "--formula", "wget"])
    #expect(infoCaskArgs == ["info", "--json=v2", "--cask", "iterm2"])
    #expect(searchFormulaArgs == ["search", "--formula", "wget"])
    #expect(searchCaskArgs == ["search", "--cask", "iterm"])
    #expect(multiInfoArgs == ["info", "--json=v2", "--formula", "wget", "curl"])
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

@Test func searchReturnsGroupedStructuredInfo() async throws {
    let runner = MockCommandRunner { _, arguments, _, _, _ in
        if arguments == ["search", "--formula", "docker"] {
            return BrewCommandResult(stdout: "docker\n", stderr: "", exitCode: 0, duration: 0.01)
        }
        if arguments == ["search", "--cask", "docker"] {
            return BrewCommandResult(
                stdout: "docker-desktop\n",
                stderr: "",
                exitCode: 0,
                duration: 0.01
            )
        }
        if arguments == ["info", "--json=v2", "--formula", "docker"] {
            return BrewCommandResult(
                stdout:
                    "{\"formulae\":[{\"name\":\"docker\",\"full_name\":\"homebrew/core/docker\",\"desc\":\"Pack and ship\",\"versions\":{\"stable\":\"27.0.0\"}}],\"casks\":[]}",
                stderr: "",
                exitCode: 0,
                duration: 0.01
            )
        }
        if arguments == ["info", "--json=v2", "--cask", "docker-desktop"] {
            return BrewCommandResult(
                stdout:
                    "{\"formulae\":[],\"casks\":[{\"token\":\"docker-desktop\",\"full_token\":\"homebrew/cask/docker-desktop\",\"name\":[\"Docker Desktop\"],\"desc\":\"Docker Desktop\",\"version\":\"4.0.0\"}]}",
                stderr: "",
                exitCode: 0,
                duration: 0.01
            )
        }
        return BrewCommandResult(stdout: "", stderr: "unexpected args", exitCode: 1, duration: 0.01)
    }

    let session = try BrewSession(
        brewPath: "/bin/sh",
        environment: BrewSession.defaultEnvironment,
        timeout: 30,
        commandRunner: runner
    )

    let result = try await session.search("docker")
    #expect(result.formulae.count == 1)
    #expect(result.formulae.first?.name == "docker")
    #expect(result.casks.count == 1)
    #expect(result.casks.first?.token == "docker-desktop")
}

@Test func searchSupportsKindFilterAndTypedOverloads() async throws {
    let runner = MockCommandRunner { _, arguments, _, _, _ in
        if arguments == ["search", "--formula", "wget"] {
            return BrewCommandResult(stdout: "wget\n", stderr: "", exitCode: 0, duration: 0.01)
        }
        if arguments == ["search", "--cask", "wget"] {
            return BrewCommandResult(stdout: "wget-app\n", stderr: "", exitCode: 0, duration: 0.01)
        }
        if arguments == ["info", "--json=v2", "--formula", "wget"] {
            return BrewCommandResult(
                stdout:
                    "{\"formulae\":[{\"name\":\"wget\",\"full_name\":\"homebrew/core/wget\",\"desc\":\"Retriever\",\"versions\":{\"stable\":\"1.25.0\"}}],\"casks\":[]}",
                stderr: "",
                exitCode: 0,
                duration: 0.01
            )
        }
        if arguments == ["info", "--json=v2", "--cask", "wget-app"] {
            return BrewCommandResult(
                stdout:
                    "{\"formulae\":[],\"casks\":[{\"token\":\"wget-app\",\"full_token\":\"custom/wget-app\",\"name\":[\"Wget App\"],\"desc\":\"GUI\",\"version\":\"1.0.0\"}]}",
                stderr: "",
                exitCode: 0,
                duration: 0.01
            )
        }
        return BrewCommandResult(stdout: "", stderr: "unexpected args", exitCode: 1, duration: 0.01)
    }

    let session = try BrewSession(
        brewPath: "/bin/sh",
        environment: BrewSession.defaultEnvironment,
        timeout: 30,
        commandRunner: runner
    )

    let formulaOnly = try await session.search("wget", for: .formula)
    #expect(formulaOnly.formulae.count == 1)
    #expect(formulaOnly.casks.isEmpty)

    let caskOnly = try await session.search("wget", for: .cask)
    #expect(caskOnly.casks.count == 1)
    #expect(caskOnly.formulae.isEmpty)

    let formulaList: [BrewFormulaInfo] = try await session.search("wget", for: BrewFormulaInfo.self)
    #expect(formulaList.count == 1)
    #expect(formulaList.first?.name == "wget")

    let caskList: [BrewCaskInfo] = try await session.search("wget", for: BrewCaskInfo.self)
    #expect(caskList.count == 1)
    #expect(caskList.first?.token == "wget-app")
}
