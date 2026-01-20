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
    static var calendar: Calendar = .current
}
