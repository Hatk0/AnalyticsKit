import Foundation

/// An interceptor that appends a set of common parameters to every event.
public final class GlobalParametersInterceptor: AnalyticsInterceptor {
    
    private let parameters: [String: Sendable]
    
    public init(parameters: [String: Sendable]) {
        self.parameters = parameters
    }
    
    public func intercept(event: AnalyticsEvent) -> AnalyticsEvent? {
        var newParameters = event.parameters ?? [:]
        
        // Merge global parameters, keeping existing event parameters if there's a conflict
        for (key, value) in parameters {
            if newParameters[key] == nil {
                newParameters[key] = value
            }
        }
        
        return BasicAnalyticsEvent(name: event.name, parameters: newParameters)
    }
}
