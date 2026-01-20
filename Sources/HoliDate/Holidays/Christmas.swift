import Foundation

public final class ChristmasHoliday: Holiday {

    public static let shared = ChristmasHoliday()

    public let id = "christmas"

    public let name = "Christmas"

    private init() {}

    public func isDuring(_ date: Date, calendar: Calendar) -> Bool {
        let year = calendar.component(.year, from: date)
        guard let start = calendar.date(from: .init(year: year, month: 12, day: 24)),
              let end = calendar.date(from: .init(year: year, month: 12, day: 26)) else {
            return false
        }
        return date >= start && date <= end
    }

    public func nextOccurrence(after date: Date, calendar: Calendar) -> Date? {
        let year = calendar.component(.year, from: date)
        guard let thisYear = calendar.date(from: .init(year: year, month: 12, day: 24)) else {
            return nil
        }
        return thisYear > date
            ? thisYear
            : calendar.date(from: .init(year: year + 1, month: 12, day: 24))
    }
}

extension HoliDate {
    public static let Christmas = ChristmasHoliday.shared
}
