import Foundation
import os.log

/// A simple analytics provider that logs everything to the console.
public final class ConsoleAnalyticsProvider: AnalyticsProvider, @unchecked Sendable {
    
    public let name: String = "Console"
    
    public init() {}
    
    public func track(event: AnalyticsEvent) {
        let params = event.parameters?.description ?? "none"
        print("[Analytics] Event: '\(event.name)' | Params: \(params)")
    }
    
    public func setUserProperty(_ value: Sendable?, for property: String) {
        let val = value != nil ? "\(value!)" : "nil"
        print("[Analytics] User Property: '\(property)' = \(val)")
    }
    
    public func identify(userId: String?) {
        print("[Analytics] Identify: \(userId ?? "Guest")")
    }
    
    public func reset() {
        print("[Analytics] Reset")
    }
}
