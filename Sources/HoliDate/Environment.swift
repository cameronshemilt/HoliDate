import Foundation

public protocol DateProvider: Sendable {
    var now: Date { get }
}

/// The default date provider that returns the system's current date and time.
public struct SystemDateProvider: DateProvider {
    public var now: Date { Date() }
}

@MainActor
enum HoliDateEnvironment {
    static var dateProvider: DateProvider = SystemDateProvider()
    // Read the system calendar afresh, while allowing deterministic preview overrides.
    static var calendar: Calendar {
        get { calendarOverride ?? .current }
        set { calendarOverride = newValue }
    }
    static var calendarOverride: Calendar?
}
