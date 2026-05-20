import Foundation

/// Command runner abstraction for testability.
/// 可测试性的命令执行抽象。
protocol BrewCommandRunning: Sendable {
    /// Executes one brew command invocation.
    /// 执行一次 brew 命令调用。
    /// - Parameters:
    ///   - executable: Absolute executable path.
    ///   - arguments: Command arguments without executable.
    ///   - environment: Environment overrides for the process.
    ///   - timeout: Timeout in seconds.
    ///   - stream: Optional line callback for progressive output.
    /// - 参数:
    ///   - executable: 可执行文件绝对路径。
    ///   - arguments: 不含可执行文件本身的命令参数。
    ///   - environment: 进程环境变量覆盖项。
    ///   - timeout: 超时时间（秒）。
    ///   - stream: 可选的逐行输出回调。
    /// - Returns: Full command result including stdout/stderr and exit code.
    /// - 返回值: 包含 stdout/stderr 和退出码的完整命令结果。
    func run(
        executable: String,
        arguments: [String],
        environment: [String: String],
        timeout: TimeInterval,
        stream: (@Sendable (String) -> Void)?
    ) async throws(BrewSessionError) -> BrewCommandResult
}

/// Process-based command runner implementation.
/// 基于 Process 的命令执行实现。
struct ProcessCommandRunner: BrewCommandRunning {
    /// Executes one brew command asynchronously using `Process`.
    /// 使用 `Process` 异步执行一次 brew 命令。
    /// - Parameters:
    ///   - executable: Absolute executable path.
    ///   - arguments: Command arguments without executable.
    ///   - environment: Environment overrides for the process.
    ///   - timeout: Timeout in seconds.
    ///   - stream: Optional line callback for progressive output.
    /// - 参数:
    ///   - executable: 可执行文件绝对路径。
    ///   - arguments: 不含可执行文件本身的命令参数。
    ///   - environment: 进程环境变量覆盖项。
    ///   - timeout: 超时时间（秒）。
    ///   - stream: 可选的逐行输出回调。
    /// - Returns: Full command result including stdout/stderr and exit code.
    /// - 返回值: 包含 stdout/stderr 和退出码的完整命令结果。
    @concurrent nonisolated func run(
        executable: String,
        arguments: [String],
        environment: [String: String],
        timeout: TimeInterval,
        stream: (@Sendable (String) -> Void)?
    ) async throws(BrewSessionError) -> BrewCommandResult {
        let command = ([executable] + arguments).joined(separator: " ")

        do {
            return try await withCheckedThrowingContinuation { continuation in
                DispatchQueue.global(qos: .userInitiated).async {
                    do {
                        let result = try runBlocking(
                            executable: executable,
                            arguments: arguments,
                            environment: environment,
                            timeout: timeout,
                            stream: stream
                        )
                        continuation.resume(returning: result)
                    } catch let error as BrewSessionError {
                        continuation.resume(throwing: error)
                    } catch {
                        continuation.resume(
                            throwing: BrewSessionError.commandFailed(
                                command: command,
                                exitCode: nil,
                                stdout: "",
                                stderr: error.localizedDescription
                            )
                        )
                    }
                }
            }
        } catch let error as BrewSessionError {
            throw error
        } catch {
            throw BrewSessionError.commandFailed(
                command: command,
                exitCode: nil,
                stdout: "",
                stderr: error.localizedDescription
            )
        }
    }

    /// Runs a command in a blocking context and returns full output.
    /// 在阻塞上下文中运行命令并返回完整输出。
    /// - Parameters:
    ///   - executable: Absolute executable path.
    ///   - arguments: Command arguments without executable.
    ///   - environment: Environment overrides for the process.
    ///   - timeout: Timeout in seconds.
    ///   - stream: Optional line callback for progressive output.
    /// - 参数:
    ///   - executable: 可执行文件绝对路径。
    ///   - arguments: 不含可执行文件本身的命令参数。
    ///   - environment: 进程环境变量覆盖项。
    ///   - timeout: 超时时间（秒）。
    ///   - stream: 可选的逐行输出回调。
    /// - Returns: Full command result including stdout/stderr and exit code.
    /// - 返回值: 包含 stdout/stderr 和退出码的完整命令结果。
    private func runBlocking(
        executable: String,
        arguments: [String],
        environment: [String: String],
        timeout: TimeInterval,
        stream: (@Sendable (String) -> Void)?
    ) throws(BrewSessionError) -> BrewCommandResult {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: executable)
        process.arguments = arguments

        var env = ProcessInfo.processInfo.environment
        for (key, value) in environment {
            env[key] = value
        }
        process.environment = env

        let stdoutPipe = Pipe()
        let stderrPipe = Pipe()
        process.standardOutput = stdoutPipe
        process.standardError = stderrPipe

        let stdoutHandle = stdoutPipe.fileHandleForReading
        let stderrHandle = stderrPipe.fileHandleForReading

        let accumulator = StreamAccumulator()
        let command = ([executable] + arguments).joined(separator: " ")
        let start = Date()
        let semaphore = DispatchSemaphore(value: 0)

        stdoutHandle.readabilityHandler = { handle in
            accumulator.consumeChunk(handle.availableData, isStdout: true, stream: stream)
        }
        stderrHandle.readabilityHandler = { handle in
            accumulator.consumeChunk(handle.availableData, isStdout: false, stream: stream)
        }

        process.terminationHandler = { _ in
            semaphore.signal()
        }

        do {
            try process.run()
        } catch {
            stdoutHandle.readabilityHandler = nil
            stderrHandle.readabilityHandler = nil
            throw BrewSessionError.commandFailed(
                command: command,
                exitCode: nil,
                stdout: "",
                stderr: error.localizedDescription
            )
        }

        let waitResult = semaphore.wait(timeout: .now() + timeout)
        if waitResult == .timedOut {
            process.terminate()
            _ = semaphore.wait(timeout: .now() + 2)
            stdoutHandle.readabilityHandler = nil
            stderrHandle.readabilityHandler = nil
            throw BrewSessionError.commandTimedOut(command: command, timeout: timeout)
        }

        stdoutHandle.readabilityHandler = nil
        stderrHandle.readabilityHandler = nil

        let extraOut = stdoutHandle.readDataToEndOfFile()
        if !extraOut.isEmpty {
            accumulator.consumeChunk(extraOut, isStdout: true, stream: stream)
        }

        let extraErr = stderrHandle.readDataToEndOfFile()
        if !extraErr.isEmpty {
            accumulator.consumeChunk(extraErr, isStdout: false, stream: stream)
        }

        let (stdoutData, stderrData) = accumulator.finalize(stream: stream)
        return BrewCommandResult(
            stdout: String(decoding: stdoutData, as: UTF8.self),
            stderr: String(decoding: stderrData, as: UTF8.self),
            exitCode: process.terminationStatus,
            duration: Date().timeIntervalSince(start)
        )
    }
}

/// Thread-safe output accumulator for stream processing.
/// 用于流处理的线程安全输出聚合器。
private final class StreamAccumulator: @unchecked Sendable {
    /// Accumulated stdout bytes.
    /// 已累积的 stdout 字节。
    private var stdoutData = Data()

    /// Accumulated stderr bytes.
    /// 已累积的 stderr 字节。
    private var stderrData = Data()

    /// Buffer for incomplete stdout lines.
    /// 不完整 stdout 行的缓冲。
    private var stdoutLineBuffer = ""

    /// Buffer for incomplete stderr lines.
    /// 不完整 stderr 行的缓冲。
    private var stderrLineBuffer = ""

    /// Lock to synchronize access to buffers.
    /// 用于同步访问缓冲的锁。
    private let lock = NSLock()

    /// Consumes one output chunk and optionally emits complete lines.
    /// 消费一个输出分块，并可选地发出完整行。
    /// - Parameters:
    ///   - data: Incoming output bytes.
    ///   - isStdout: `true` when chunk is from stdout, otherwise stderr.
    ///   - stream: Optional line callback.
    /// - 参数:
    ///   - data: 输入的输出字节。
    ///   - isStdout: 为 `true` 表示来自 stdout，否则为 stderr。
    ///   - stream: 可选逐行回调。
    /// - Returns: No return value.
    /// - 返回值: 无返回值。
    func consumeChunk(_ data: Data, isStdout: Bool, stream: (@Sendable (String) -> Void)?) {
        guard !data.isEmpty else { return }

        lock.lock()
        if isStdout {
            stdoutData.append(data)
        } else {
            stderrData.append(data)
        }
        lock.unlock()

        guard let stream else { return }
        let chunkText = String(decoding: data, as: UTF8.self)

        lock.lock()
        if isStdout {
            stdoutLineBuffer.append(chunkText)
            let emitted = flushCompleteLines(from: &stdoutLineBuffer)
            lock.unlock()
            emitted.forEach(stream)
        } else {
            stderrLineBuffer.append(chunkText)
            let emitted = flushCompleteLines(from: &stderrLineBuffer)
            lock.unlock()
            emitted.forEach(stream)
        }
    }

    /// Flushes remaining line fragments and returns accumulated bytes.
    /// 刷新剩余行片段并返回已累积字节。
    /// - Parameter stream: Optional callback for final non-newline fragments.
    /// - 参数 stream: 对最终非换行片段的可选回调。
    /// - Returns: Tuple containing all stdout and stderr bytes.
    /// - 返回值: 包含完整 stdout 与 stderr 字节的元组。
    func finalize(stream: (@Sendable (String) -> Void)?) -> (stdout: Data, stderr: Data) {
        lock.lock()
        let stdout = stdoutData
        let stderr = stderrData
        let remainingOut = stdoutLineBuffer
        let remainingErr = stderrLineBuffer
        stdoutLineBuffer = ""
        stderrLineBuffer = ""
        lock.unlock()

        if let stream {
            if !remainingOut.isEmpty { stream(remainingOut) }
            if !remainingErr.isEmpty { stream(remainingErr) }
        }

        return (stdout, stderr)
    }

    /// Splits buffered text into complete lines and preserves trailing fragment.
    /// 将缓冲文本拆分为完整行并保留尾部残片。
    /// - Parameter buffer: Mutable line buffer.
    /// - 参数 buffer: 可变行缓冲。
    /// - Returns: Extracted complete lines without newline characters.
    /// - 返回值: 提取出的完整行（不含换行符）。
    private func flushCompleteLines(from buffer: inout String) -> [String] {
        var lines: [String] = []

        while let newline = buffer.firstIndex(where: { $0 == "\n" || $0 == "\r" }) {
            let line = String(buffer[..<newline])
            lines.append(line)

            let next = buffer.index(after: newline)
            buffer.removeSubrange(..<next)
        }

        return lines
    }
}
