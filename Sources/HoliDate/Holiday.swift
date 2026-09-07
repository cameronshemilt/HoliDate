import Foundation

public protocol Holiday: Sendable, Identifiable {
    static var shared: Self { get }

    var id: String { get }

    var name: String { get }

    func isDuring(_ date: Date, calendar: Calendar) -> Bool

    func nextOccurrence(
        after date: Date,
        calendar: Calendar
    ) -> Date?
}
