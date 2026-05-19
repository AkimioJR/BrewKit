import Foundation

@testable import BrewKit

/// Mock runner for deterministic BrewSession tests.
/// 用于 BrewSession 确定性测试的模拟执行器。
struct MockCommandRunner: BrewCommandRunning {
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

