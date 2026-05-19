import Foundation
import Testing

@testable import BrewKit

/// Downloads remote JSON payload with a deterministic timeout.
/// 使用确定性的超时时间下载远程 JSON 载荷。
private func fetchRemoteJSON(
    from urlString: String,
    timeout: TimeInterval = 180,
    retries: Int = 2
) async throws -> Data
{
    guard let url = URL(string: urlString) else {
        throw BrewSessionError.commandFailed(
            command: "GET \(urlString)", exitCode: nil, stdout: "", stderr: "Invalid URL")
    }

    var lastError: Error?
    for attempt in 1...max(retries, 1) {
        do {
            let configuration = URLSessionConfiguration.ephemeral
            configuration.timeoutIntervalForRequest = timeout
            configuration.timeoutIntervalForResource = timeout
            let session = URLSession(configuration: configuration)

            let (data, response) = try await session.data(from: url)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw BrewSessionError.commandFailed(
                    command: "GET \(urlString)",
                    exitCode: nil,
                    stdout: "",
                    stderr: "Non-HTTP response")
            }

            guard (200...299).contains(httpResponse.statusCode) else {
                throw BrewSessionError.commandFailed(
                    command: "GET \(urlString)",
                    exitCode: Int32(httpResponse.statusCode),
                    stdout: "",
                    stderr: "Unexpected status: \(httpResponse.statusCode)")
            }

            return data
        } catch {
            lastError = error
            if attempt < retries {
                try await Task.sleep(for: .seconds(1))
            }
        }
    }

    if let lastError {
        throw lastError
    }
    throw BrewSessionError.commandFailed(
        command: "GET \(urlString)", exitCode: nil, stdout: "", stderr: "Unknown download error")
}

@Test func formulaAPIListCanDecodeAllEntries() async throws {
    let data = try await fetchRemoteJSON(from: "https://formulae.brew.sh/api/formula.json")

    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let formulae = try decoder.decode([BrewFormulaInfo].self, from: data)

    #expect(formulae.isEmpty == false)
    for formula in formulae {
        #expect(formula.name.isEmpty == false)
        #expect(formula.desc?.isEmpty == false || formula.desc == nil)
    }
}

@Test func caskAPIListCanDecodeAllEntries() async throws {
    let data = try await fetchRemoteJSON(from: "https://formulae.brew.sh/api/cask.json")

    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    let casks = try decoder.decode([BrewCaskInfo].self, from: data)

    #expect(casks.isEmpty == false)
    for cask in casks {
        #expect(cask.token.isEmpty == false)
        #expect(cask.name?.isEmpty == false || cask.name == nil)
    }
}

