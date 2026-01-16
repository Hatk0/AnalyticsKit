import Foundation

/// Protocol that any analytics service (Mixpanel, Amplitude, etc.) must implement.
public protocol AnalyticsProvider: Sendable {
    /// The name of the provider (for debugging purposes).
    var name: String { get }
    
    /// Tracks a specific event.
    /// - Parameter event: The event to track.
    func track(event: AnalyticsEvent)
    
    /// Sets a user property.
    /// - Parameters:
    ///   - value: The value of the property (must be Sendable).
    ///   - property: The name of the property.
    func setUserProperty(_ value: Sendable?, for property: String)
    
    /// Identifies the user.
    /// - Parameter userId: The unique identifier for the user.
    func identify(userId: String?)
    
    /// Resets the current user session (useful on logout).
    func reset()
}

public extension AnalyticsProvider {
    
    func setUserProperty(_ value: Sendable?, for property: String) {}
    func identify(userId: String?) {}
    func reset() {}
}
