import Foundation

/// Typed line event used by Brew streaming APIs.
/// Brew 流式 API 使用的强类型行事件。
public typealias BrewStreamEvent = Result<String, BrewSessionError>

/// Typed stream used by Brew streaming APIs.
/// Brew 流式 API 使用的强类型流。
public typealias BrewStream = AsyncStream<BrewStreamEvent>
