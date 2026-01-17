import Foundation

/// A middleware that can intercept, modify, or block events before they reach providers.
public protocol AnalyticsInterceptor: Sendable {
    /// Intercepts an event.
    /// - Parameter event: The original event.
    /// - Returns: The modified event, or `nil` if the event should be dropped.
    func intercept(event: AnalyticsEvent) -> AnalyticsEvent?
}
