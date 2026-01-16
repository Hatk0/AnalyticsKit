import Foundation
import os

/// The central hub for analytics. Manages multiple providers and dispatches events to all of them.
/// This class is thread-safe and optimized for high performance using modern locking.
public final class AnalyticsManager: @unchecked Sendable {
    
    /// The shared instance of the manager.
    public static let shared = AnalyticsManager()
    
    /// Global toggle to enable or disable all analytics tracking.
    public var isEnabled: Bool = true
    
    /// When enabled, the manager will print debug information about event routing.
    public var isLoggingEnabled: Bool = false
    
    // Modern high-performance lock provided by Apple for Swift (iOS 16+)
    private let lock = OSAllocatedUnfairLock(initialState: [AnalyticsProvider]())
    
    private init() {}
    
    /// Registers a list of providers to be used.
    public func register(providers: [AnalyticsProvider]) {
        lock.withLock { state in
            state = providers
        }
        log("Registered \(providers.count) providers")
    }
    
    /// Adds a single provider to the list.
    public func add(provider: AnalyticsProvider) {
        lock.withLock { state in
            state.append(provider)
        }
        log("Added provider: \(provider.name)")
    }
    
    /// Tracks an event across all registered providers.
    public func track(event: AnalyticsEvent) {
        guard isEnabled else { return }
        
        let currentProviders = lock.withLock { $0 }
        
        log("Tracking event: '\(event.name)'")
        currentProviders.forEach { $0.track(event: event) }
    }
    
    /// Convenience method to track an event by name and parameters.
    public func track(name: String, parameters: [String: Sendable]? = nil) {
        let event = BasicAnalyticsEvent(name: name, parameters: parameters)
        track(event: event)
    }
    
    /// Sets a user property across all providers.
    public func setUserProperty(_ value: Sendable?, for property: String) {
        guard isEnabled else { return }
        let currentProviders = lock.withLock { $0 }
        currentProviders.forEach { $0.setUserProperty(value, for: property) }
    }
    
    /// Identifies the user across all providers.
    public func identify(userId: String?) {
        guard isEnabled else { return }
        let currentProviders = lock.withLock { $0 }
        currentProviders.forEach { $0.identify(userId: userId) }
    }
    
    /// Resets all registered providers.
    public func reset() {
        let currentProviders = lock.withLock { $0 }
        currentProviders.forEach { $0.reset() }
        log("Reset all providers")
    }
    
    // MARK: - Private
    
    private func log(_ message: String) {
        guard isLoggingEnabled else { return }
        print("[AnalyticsManager] \(message)")
    }
}
