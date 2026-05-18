import Foundation

/// Shared analytics model used by formula and cask info payloads.
/// formula 与 cask 信息载荷共用的统计模型。
public struct BrewAnalytics: Codable, Sendable {
    /// Install counts grouped by period.
    /// 按时间段分组的安装次数。
    public let install: BrewAnalyticsPeriod?

    /// Install-on-request counts grouped by period.
    /// 按时间段分组的手动安装次数。
    public let installOnRequest: BrewAnalyticsPeriod?

    /// Build error counts grouped by period.
    /// 按时间段分组的构建错误次数。
    public let buildError: BrewAnalyticsPeriod?
}

/// Analytics metrics for 30/90/365 day windows.
/// 30/90/365 天窗口的统计指标。
public struct BrewAnalyticsPeriod: Codable, Sendable {
    /// Last 30 days metrics.
    /// 最近 30 天指标。
    public let days30: [String: Int]?

    /// Last 90 days metrics.
    /// 最近 90 天指标。
    public let days90: [String: Int]?

    /// Last 365 days metrics.
    /// 最近 365 天指标。
    public let days365: [String: Int]?

    enum CodingKeys: String, CodingKey {
        case days30 = "30d"
        case days90 = "90d"
        case days365 = "365d"
    }
}
