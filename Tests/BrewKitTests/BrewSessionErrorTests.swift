import Testing

@testable import BrewKit

@Test func brewSessionErrorDescriptions() {
    let notFound = BrewSessionError.brewNotFound(candidates: ["/opt/homebrew/bin/brew"])
    let timeout = BrewSessionError.commandTimedOut(command: "brew update", timeout: 30)

    #expect(notFound.errorDescription?.contains("not found") == true)
    #expect(timeout.errorDescription?.contains("timed out") == true)
}

