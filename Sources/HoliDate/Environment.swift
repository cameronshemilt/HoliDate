import Foundation

public protocol DateProvider: Sendable {
    var now: Date { get }
}

public struct SystemDateProvider: DateProvider {
    public var now: Date { Date() }
}

@MainActor
enum HoliDateEnvironment {
    static var dateProvider: DateProvider = SystemDateProvider()
}
