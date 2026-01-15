import Foundation

public final class EasterHoliday: Holiday {

    public static let shared = EasterHoliday()

    public let id = "easter"
    public let name = "Easter"

    private init() {}

    public func isDuring(_ date: Date, calendar: Calendar) -> Bool {
        guard let easter = easterDate(
            year: calendar.component(.year, from: date),
            calendar: calendar
        ) else { return false }

        return calendar.isDate(date, inSameDayAs: easter)
    }

    public func nextOccurrence(after date: Date, calendar: Calendar) -> Date? {
        let year = calendar.component(.year, from: date)
        let thisYear = easterDate(year: year, calendar: calendar)!
        return thisYear > date
            ? thisYear
            : easterDate(year: year + 1, calendar: calendar)
    }

    private func easterDate(
        year: Int,
        calendar: Calendar
    ) -> Date? {
        let a = year % 19
        let b = year / 100
        let c = year % 100
        let d = b / 4
        let e = b % 4
        let f = (b + 8) / 25
        let g = (b - f + 1) / 3
        let h = (19 * a + b - d - g + 15) % 30
        let i = c / 4
        let k = c % 4
        let l = (32 + 2 * e + 2 * i - h - k) % 7
        let m = (a + 11 * h + 22 * l) / 451
        let month = (h + l - 7 * m + 114) / 31
        let day = ((h + l - 7 * m + 114) % 31) + 1

        return calendar.date(from: .init(year: year, month: month, day: day))
    }
}

extension HoliDate {
    public static let Easter = EasterHoliday.shared
}
