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

final class AnalyticsKitTests: XCTestCase {
    
    func testAnalyticsManagerDispatchesToAllProviders() {
        let manager = AnalyticsManager.shared
        let provider1 = MockProvider()
        let provider2 = MockProvider()
        
        manager.register(providers: [provider1, provider2])
        
        let eventName = "test_event"
        let params = ["key": "value"]
        manager.track(name: eventName, parameters: params)
        
        XCTAssertEqual(provider1.trackedEvents.count, 1)
        XCTAssertEqual(provider1.trackedEvents.first?.name, eventName)
        XCTAssertEqual(provider1.trackedEvents.first?.parameters?["key"] as? String, "value")
        
        XCTAssertEqual(provider2.trackedEvents.count, 1)
        XCTAssertEqual(provider2.trackedEvents.first?.name, eventName)
    }
    
    func testIdentifyDispatchesToAllProviders() {
        let manager = AnalyticsManager.shared
        let provider1 = MockProvider()
        manager.register(providers: [provider1])
        
        manager.identify(userId: "user_123")
        XCTAssertEqual(provider1.identifiedUserId, "user_123")
        
        manager.identify(userId: nil)
        XCTAssertNil(provider1.identifiedUserId)
    }
    
    func testUserPropertiesDispatchToAllProviders() {
        let manager = AnalyticsManager.shared
        let provider1 = MockProvider()
        manager.register(providers: [provider1])
        
        manager.setUserProperty("gold", for: "membership")
        XCTAssertEqual(provider1.userProperties["membership"] as? String, "gold")
    }
    
    func testResetDispatchesToAllProviders() {
        let manager = AnalyticsManager.shared
        let provider1 = MockProvider()
        manager.register(providers: [provider1])
        
        manager.reset()
        XCTAssertTrue(provider1.wasReset)
    }
    
    func testEnabledToggle() {
        let manager = AnalyticsManager.shared
        let provider1 = MockProvider()
        manager.register(providers: [provider1])
        
        manager.isEnabled = false
        manager.track(name: "hidden_event")
        
        XCTAssertEqual(provider1.trackedEvents.count, 0)
        
        manager.isEnabled = true
        manager.track(name: "visible_event")
        XCTAssertEqual(provider1.trackedEvents.count, 1)
    }
}
