import Foundation

/// Codable JSON value container for dynamic nested API payloads.
/// 用于动态嵌套 API 载荷的可编解码 JSON 值容器。
public enum BrewJSONValue: Codable, Sendable {
    /// String value.
    /// 字符串值。
    case string(String)

    /// Numeric value stored as `Double`.
    /// 以 `Double` 存储的数值。
    case number(Double)

    /// Boolean value.
    /// 布尔值。
    case bool(Bool)

    /// Object value.
    /// 对象值。
    case object([String: BrewJSONValue])

    /// Array value.
    /// 数组值。
    case array([BrewJSONValue])

    /// Null value.
    /// 空值。
    case null

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if container.decodeNil() {
            self = .null
            return
        }
        if let boolValue = try? container.decode(Bool.self) {
            self = .bool(boolValue)
            return
        }
        if let intValue = try? container.decode(Int.self) {
            self = .number(Double(intValue))
            return
        }
        if let doubleValue = try? container.decode(Double.self) {
            self = .number(doubleValue)
            return
        }
        if let stringValue = try? container.decode(String.self) {
            self = .string(stringValue)
            return
        }
        if let arrayValue = try? container.decode([BrewJSONValue].self) {
            self = .array(arrayValue)
            return
        }
        if let objectValue = try? container.decode([String: BrewJSONValue].self) {
            self = .object(objectValue)
            return
        }
        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Unsupported JSON value type"
        )
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let value):
            try container.encode(value)
        case .number(let value):
            try container.encode(value)
        case .bool(let value):
            try container.encode(value)
        case .object(let value):
            try container.encode(value)
        case .array(let value):
            try container.encode(value)
        case .null:
            try container.encodeNil()
        }
    }
}
