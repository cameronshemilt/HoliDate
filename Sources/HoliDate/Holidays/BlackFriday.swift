import Foundation

public final class BlackFridayHoliday: Holiday {

    public static let shared = BlackFridayHoliday()

    public let id = "black-friday"
    public let name = "Black Friday"

    private init() {}

    public func isDuring(_ date: Date, calendar: Calendar) -> Bool {
        guard let blackFriday = blackFridayDate(
            year: calendar.component(.year, from: date),
            calendar: calendar
        ) else { return false }

        return calendar.isDate(date, inSameDayAs: blackFriday)
    }

    public func nextOccurrence(
        after date: Date,
        calendar: Calendar
    ) -> Date? {
        let year = calendar.component(.year, from: date)

        if let thisYear = blackFridayDate(year: year, calendar: calendar),
           thisYear > date {
            return thisYear
        }

        return blackFridayDate(year: year + 1, calendar: calendar)
    }

    // MARK: - Calculation

    private func blackFridayDate(
        year: Int,
        calendar: Calendar
    ) -> Date? {
        // November 1st of the given year
        guard let november = calendar.date(
            from: DateComponents(year: year, month: 11, day: 1)
        ) else { return nil }

        // Find first Thursday in November
        let weekday = calendar.component(.weekday, from: november)
        let thursday = 5 // Thursday in Gregorian calendar (1 = Sunday)

        let daysUntilThursday =
            (thursday - weekday + 7) % 7

        guard let firstThursday = calendar.date(
            byAdding: .day,
            value: daysUntilThursday,
            to: november
        ) else { return nil }

        // Fourth Thursday = Thanksgiving
        guard let thanksgiving = calendar.date(
            byAdding: .day,
            value: 21,
            to: firstThursday
        ) else { return nil }

        // Black Friday = day after Thanksgiving
        return calendar.date(
            byAdding: .day,
            value: 1,
            to: thanksgiving
        )
    }
}

extension HoliDate {
    public static let BlackFriday = BlackFridayHoliday.shared
}
