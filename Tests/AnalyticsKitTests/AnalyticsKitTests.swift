import XCTest
@testable import AnalyticsKit

final class MockProvider: AnalyticsProvider, @unchecked Sendable {
    var name: String = "Mock"
    var trackedEvents: [AnalyticsEvent] = []
    var userProperties: [String: Sendable?] = [:]
    var identifiedUserId: String?
    var wasReset = false
    
    func track(event: AnalyticsEvent) {
        trackedEvents.append(event)
    }
    
    func setUserProperty(_ value: Sendable?, for property: String) {
        userProperties[property] = value
    }
    
    func identify(userId: String?) {
        identifiedUserId = userId
    }
    
    func reset() {
        wasReset = true
    }
}

final class MockInterceptor: AnalyticsInterceptor {
    var shouldDrop = false
    var nameToAppend = ""
    
    func intercept(event: AnalyticsEvent) -> AnalyticsEvent? {
        if shouldDrop { return nil }
        if !nameToAppend.isEmpty {
            return BasicAnalyticsEvent(name: event.name + nameToAppend, parameters: event.parameters)
        }
        return event
    }
}

final class AnalyticsKitTests: XCTestCase {
    
    func testAnalyticsManagerDispatchesToAllProviders() {
        let manager = AnalyticsManager.shared
        let provider1 = MockProvider()
        let provider2 = MockProvider()
        
        manager.register(providers: [provider1, provider2])
        manager.register(interceptors: [])
        
        let eventName = "test_event"
        let params = ["key": "value"]
        manager.track(name: eventName, parameters: params)
        
        XCTAssertEqual(provider1.trackedEvents.count, 1)
        XCTAssertEqual(provider1.trackedEvents.first?.name, eventName)
        XCTAssertEqual(provider1.trackedEvents.first?.parameters?["key"] as? String, "value")
    }
    
    func testSessionInterceptorLifecycle() {
        let manager = AnalyticsManager.shared
        let provider = MockProvider()
        let sessionInterceptor = SessionInterceptor()
        
        manager.register(providers: [provider])
        manager.register(interceptors: [sessionInterceptor])
        
        // Initial session
        manager.track(name: "start")
        let sessionId1 = provider.trackedEvents.first?.parameters?["session_id"] as? String
        let duration1 = provider.trackedEvents.first?.parameters?["session_duration"] as? TimeInterval
        
        XCTAssertNotNil(sessionId1)
        XCTAssertNotNil(duration1)
        
        // Wait a bit and track again
        Thread.sleep(forTimeInterval: 0.1)
        manager.track(name: "middle")
        let duration2 = provider.trackedEvents.last?.parameters?["session_duration"] as? TimeInterval
        XCTAssertGreaterThan(duration2 ?? 0, duration1 ?? 0)
        
        // Restart session
        sessionInterceptor.startSession()
        manager.track(name: "new_session")
        let sessionId2 = provider.trackedEvents.last?.parameters?["session_id"] as? String
        XCTAssertNotEqual(sessionId1, sessionId2)
        
        // End session
        let finalDuration = sessionInterceptor.endSession()
        XCTAssertGreaterThan(finalDuration, 0)
        
        manager.track(name: "after_end")
        let durationAfterEnd = provider.trackedEvents.last?.parameters?["session_duration"] as? TimeInterval
        XCTAssertNil(durationAfterEnd, "Duration should not be attached after session ends")
    }
    
    func testGlobalParametersInterceptor() {
        let manager = AnalyticsManager.shared
        let provider = MockProvider()
        let globalInterceptor = GlobalParametersInterceptor(parameters: ["app_version": "1.0.0"])
        
        manager.register(providers: [provider])
        manager.register(interceptors: [globalInterceptor])
        
        manager.track(name: "login")
        XCTAssertEqual(provider.trackedEvents.first?.parameters?["app_version"] as? String, "1.0.0")
    }
}
