import Testing
import Foundation
@testable import HoliDate

@Test
@MainActor
func currentHolidaysReturnsMultipleActiveHolidays() {
    // Create multiple test holidays that are active on the same day
    final class NewYearsDay: Holiday {
        static let shared = NewYearsDay()
        let id = "new-years-day"
        let name = "New Year's Day"
        private init() {}

        func isDuring(_ date: Date, calendar: Calendar) -> Bool {
            calendar.component(.month, from: date) == 1 &&
            calendar.component(.day, from: date) == 1
        }

        func nextOccurrence(after date: Date, calendar: Calendar) -> Date? {
            nil
        }
    }

    final class NewYearsEve: Holiday {
        static let shared = NewYearsEve()
        let id = "new-years-eve"
        let name = "New Year's Eve"
        private init() {}

        func isDuring(_ date: Date, calendar: Calendar) -> Bool {
            calendar.component(.month, from: date) == 12 &&
            calendar.component(.day, from: date) == 31
        }

        func nextOccurrence(after date: Date, calendar: Calendar) -> Date? {
            nil
        }
    }

    // Test on New Year's Day
    let newYearsDate = Calendar.current.date(
        from: .init(year: 2025, month: 1, day: 1)
    )!

    withHoliDatePreview(date: newYearsDate, holidays: [NewYearsDay.shared, NewYearsEve.shared]) {
        let currentHolidays = CurrentHolidays().wrappedValue
        #expect(currentHolidays.count == 1)
        #expect(currentHolidays.contains { $0.id == "new-years-day" })
    }

    // Test on New Year's Eve
    let newYearsEveDate = Calendar.current.date(
        from: .init(year: 2025, month: 12, day: 31)
    )!

    withHoliDatePreview(date: newYearsEveDate, holidays: [NewYearsDay.shared, NewYearsEve.shared]) {
        let currentHolidays = CurrentHolidays().wrappedValue
        #expect(currentHolidays.count == 1)
        #expect(currentHolidays.contains { $0.id == "new-years-eve" })
    }
}

@Test
@MainActor
func currentHolidaysReturnsEmptyWhenNoHolidaysActive() {
    let randomDate = Calendar.current.date(
        from: .init(year: 2025, month: 6, day: 15)
    )!

    withHoliDatePreview(date: randomDate, holidays: [HoliDate.Christmas, HoliDate.Easter]) {
        let currentHolidays = CurrentHolidays().wrappedValue
        #expect(currentHolidays.isEmpty)
    }
}

@Test
@MainActor
func currentHolidaysUsesEnvironmentCalendar() {
    // Create a custom calendar with a different timezone
    var calendar = Calendar.current
    calendar.timeZone = TimeZone(identifier: "America/New_York")!

    let christmasDate = calendar.date(
        from: .init(year: 2025, month: 12, day: 25, hour: 12)
    )!

    withHoliDatePreview(date: christmasDate, holidays: [HoliDate.Christmas], calendar: calendar) {
        let currentHolidays = CurrentHolidays().wrappedValue
        #expect(!currentHolidays.isEmpty)
        #expect(currentHolidays.contains { $0.id == "christmas" })
    }
}
