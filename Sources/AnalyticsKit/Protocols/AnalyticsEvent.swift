import Foundation

/// Protocol that describes an event to be tracked.
/// To comply with Swift 6 strict concurrency, all event data must be Sendable.
public protocol AnalyticsEvent: Sendable {
    /// The name of the event.
    var name: String { get }
    
    /// The parameters associated with the event.
    /// Values must be Sendable (e.g., String, Int, Double, Bool, Date, URL, etc.).
    var parameters: [String: Sendable]? { get }
}

/// A default implementation for common event types.
public struct BasicAnalyticsEvent: AnalyticsEvent {
    public let name: String
    private let _parameters: [String: Sendable]?

    public var parameters: [String: Sendable]? { _parameters }
    
    public init(name: String, parameters: [String: Sendable]? = nil) {
        self.name = name
        self._parameters = parameters
    }
}
