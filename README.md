# AnalyticsKit

A lightweight, protocol-oriented analytics wrapper for iOS application. This library allows you to easily plug and swap different analytics services without changing your business logic.

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-iOS%20|%20macOS%20|%20tvOS%20|%20watchOS%20|%20visionOS-blue.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

## Features

✅ **Protocol-Oriented** - Define your events and providers using simple, flexible protocols  
✅ **Multi-Provider** - Send events to multiple backends (Mixpanel, Amplitude, etc.) simultaneously  
✅ **Easy to Swap** - Change your analytics infrastructure by just adding or removing a provider  
✅ **Type-Safe** - Use enums and structs for your events instead of raw strings  
✅ **No External Dependencies** - Keep your project lean and avoid dependency hell  
✅ **Testability** - Easily mock analytics for unit testing  
✅ **Middleware (Interceptors)** - Intercept, modify, or block events  
✅ **Session Lifecycle** - Track session ID, start time, and duration automatically

## Installation

### Swift Package Manager

Add AnalyticsKit to your project via Xcode or Package.swift:

```swift
dependencies: [
    .package(url: "https://github.com/YourUsername/AnalyticsKit.git", from: "1.1.0")
]
```

## Quick Start

### 1. Define Your Events

Create an enum or struct conforming to `AnalyticsEvent` for type-safe tracking:

```swift
import AnalyticsKit

enum AppEvent: AnalyticsEvent {
    case login(method: String)
    case purchase(productId: String, price: Double)
    
    var name: String {
        switch self {
        case .login: return "login"
        case .purchase: return "purchase"
        }
    }
    
    var parameters: [String: Sendable]? {
        switch self {
        case .login(let method):
            return ["method": method]
        case .purchase(let id, let price):
            return ["product_id": id, "price": price]
        }
    }
}
```

### 2. Set Up Providers & Middlewares

Register your providers and interceptors at the app's entry point:

```swift
import AnalyticsKit

let manager = AnalyticsManager.shared

// 1. Setup Providers
manager.register(providers: [
    ConsoleAnalyticsProvider()
])

// 2. Setup Interceptors (Middleware)
let sessionInterceptor = SessionInterceptor()
manager.register(interceptors: [
    sessionInterceptor,
    GlobalParametersInterceptor(parameters: ["app_version": "1.1.0"])
])
```

### 3. Track Events

```swift
// Track using type-safe event
AnalyticsManager.shared.track(event: AppEvent.login(method: "google"))
```

### 4. Session Management

```swift
// The SessionInterceptor automatically adds 'session_id' and 'session_duration' 
// to every event.

// Manually restart session
sessionInterceptor.startSession()

// End session (stops attaching duration)
sessionInterceptor.endSession()
```

## Advanced Usage

### Navigation Interceptors (Middleware)

```swift
struct ValidationInterceptor: AnalyticsInterceptor {
    func intercept(event: AnalyticsEvent) -> AnalyticsEvent? {
        // Drop events that don't have a required parameter
        if event.name == "purchase" && event.parameters?["price"] == nil {
            return nil 
        }
        return event
    }
}

AnalyticsManager.shared.add(interceptor: ValidationInterceptor())
```

### Typed Events (Best Practices)

Always use enums for type safety and avoid naming conflicts:

```swift
enum OnboardingEvent: AnalyticsEvent {
    case started
    case stepCompleted(step: Int)
    
    var name: String {
        switch self {
        case .started: return "onboarding_started"
        case .stepCompleted: return "onboarding_step_completed"
        }
    }
    
    var parameters: [String: Sendable]? {
        switch self {
        case .started: return nil
        case .stepCompleted(let step): return ["step_index": step]
        }
    }
}
```

### Creating a Custom Provider

To integrate a service like Mixpanel or Amplitude, simply implement the `AnalyticsProvider` protocol:

```swift
import AnalyticsKit
// import SomeThirdPartySDK

class MyCustomProvider: AnalyticsProvider {
    let name: String = "MyProvider"
    
    func track(event: AnalyticsEvent) {
        // SomeSDK.logEvent(event.name, parameters: event.parameters)
    }
    
    func setUserProperty(_ value: Sendable?, for property: String) {
        // SomeSDK.setUserProperty(property, value: value)
    }
    
    func identify(userId: String?) {
        // SomeSDK.identify(userId: userId)
    }
    
    func reset() {
        // SomeSDK.reset()
    }
}
```

## Testing

You can create a `MockProvider` to verify analytics in your unit tests:

```swift
final class MockProvider: AnalyticsProvider {
    var trackedEvents: [AnalyticsEvent] = []
    
    func track(event: AnalyticsEvent) {
        trackedEvents.append(event)
    }
    
    func setUserProperty(_ value: Sendable?, for property: String) {}
    func identify(userId: String?) {}
    func reset() {}
}

func testLoginEvent() {
    let mock = MockProvider()
    AnalyticsManager.shared.register(providers: [mock])
    
    AnalyticsManager.shared.track(event: AppEvent.login(method: "email"))
    
    XCTAssertEqual(mock.trackedEvents.first?.name, "login")
}
```

## API Overview

### AnalyticsManager Methods

- `register(providers:)` - Register an array of analytics providers
- `register(interceptors:)` - Register an array of interceptors
- `track(event:)` - Send a conforming `AnalyticsEvent` to all providers
- `identify(userId:)` - Set the unique identifier for the current user
- `setUserProperty(_:for:)` - Set a global user attribute
- `reset()` - Clear user identity and reset providers

## Requirements

- Swift 5.9+
- iOS 16.0+ / macOS 13.0+ / tvOS 16.0+ / watchOS 9.0+ / visionOS 1.0+

## License

AnalyticsKit is released under the MIT license. See LICENSE for details.

## Author

Dmitry Yastrebov

## Contributing

Contributions are welcome! Please open an issue or submit a pull request.
