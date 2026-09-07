import Testing
import Foundation
@testable import HoliDate

@Test
@MainActor
func christmasDetectedOnChristmas() {
    let date = Calendar.current.date(
        from: .init(year: 2025, month: 12, day: 25)
    )!

    withHoliDatePreview(date: date, holidays: [HoliDate.Christmas]) {
        #expect(IsHolidayToday(HoliDate.Christmas).wrappedValue)
    }
}

@Test
@MainActor
func christmasDetectedOnChristmasEve() {
    let christmasEve = Calendar.current.date(
        from: .init(year: 2025, month: 12, day: 24)
    )!

    withHoliDatePreview(date: christmasEve, holidays: [HoliDate.Christmas]) {
        #expect(IsHolidayToday(HoliDate.Christmas).wrappedValue)
    }
}

@Test
@MainActor
func christmasDetectedOnBoxingDay() {
    let boxingDay = Calendar.current.date(
        from: .init(year: 2025, month: 12, day: 26)
    )!

    withHoliDatePreview(date: boxingDay, holidays: [HoliDate.Christmas]) {
        #expect(IsHolidayToday(HoliDate.Christmas).wrappedValue)
    }
}

@Test
@MainActor
func christmasNotDetectedOutsideRange() {
    let notChristmas = Calendar.current.date(
        from: .init(year: 2025, month: 12, day: 27)
    )!

    withHoliDatePreview(date: notChristmas, holidays: [HoliDate.Christmas]) {
        #expect(!IsHolidayToday(HoliDate.Christmas).wrappedValue)
    }
}

@Test
@MainActor
func christmasNextOccurrenceHandlesYearBoundary() {
    let calendar = Calendar.current

    // Test from late December after Christmas
    let lateDecember = calendar.date(
        from: .init(year: 2025, month: 12, day: 27)
    )!

    let nextChristmas = HoliDate.Christmas.nextOccurrence(after: lateDecember, calendar: calendar)
    #expect(nextChristmas != nil)

    if let nextChristmas = nextChristmas {
        let year = calendar.component(.year, from: nextChristmas)
        #expect(year == 2026)
    }
}
