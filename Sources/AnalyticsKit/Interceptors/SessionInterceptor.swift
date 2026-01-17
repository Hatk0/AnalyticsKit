import Foundation
import os

/// An interceptor that injects session-related metadata into every event.
/// Supports manual and automatic session lifecycle management.
public final class SessionInterceptor: AnalyticsInterceptor, @unchecked Sendable {
    
    private struct SessionState {
        var id: String
        var startTime: Date
        var isEnded: Bool = false
    }
    
    private let sessionKey: String
    private let durationKey: String
    private let lock = OSAllocatedUnfairLock(initialState: SessionState(id: UUID().uuidString, startTime: Date()))
    
    public init(sessionKey: String = "session_id", durationKey: String = "session_duration") {
        self.sessionKey = sessionKey
        self.durationKey = durationKey
    }
    
    /// The current session ID.
    public var currentSessionId: String {
        lock.withLock { $0.id }
    }
    
    /// The time when the current session started.
    public var sessionStartTime: Date {
        lock.withLock { $0.startTime }
    }
    
    /// Starts a new session, resetting the ID and start time.
    public func startSession() {
        let newId = UUID().uuidString
        let now = Date()
        lock.withLock { state in
            state.id = newId
            state.startTime = now
            state.isEnded = false
        }
    }
    
    /// Ends the current session and returns the total duration.
    @discardableResult
    public func endSession() -> TimeInterval {
        let now = Date()
        return lock.withLock { state in
            let duration = now.timeIntervalSince(state.startTime)
            state.isEnded = true
            return duration
        }
    }
    
    public func intercept(event: AnalyticsEvent) -> AnalyticsEvent? {
        let (id, startTime, isEnded) = lock.withLock { ($0.id, $0.startTime, $0.isEnded) }
        
        // If the session is ended, we don't attach session info or we could start a new one
        // For simplicity, we just attach the last known session info
        
        var newParameters = event.parameters ?? [:]
        newParameters[sessionKey] = id
        
        if !isEnded {
            let duration = Date().timeIntervalSince(startTime)
            newParameters[durationKey] = duration
        }
        
        return BasicAnalyticsEvent(name: event.name, parameters: newParameters)
    }
}
