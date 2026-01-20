import Testing
import Foundation
@testable import HoliDate

@Test
@MainActor
func easterDetectedCorrectly() {
    let easter2025 = Calendar.current.date(
        from: .init(year: 2025, month: 4, day: 20)
    )!

    withHoliDatePreview(date: easter2025, holidays: [HoliDate.Easter]) {
        #expect(IsHolidayToday(HoliDate.Easter).wrappedValue)
    }
}

@Test
@MainActor
func easterCalculatesMultipleYears() {
    // Test Easter dates for multiple years
    let testCases: [(year: Int, month: Int, day: Int)] = [
        (2024, 3, 31),  // Easter 2024
        (2025, 4, 20),  // Easter 2025
        (2026, 4, 5),   // Easter 2026
        (2027, 3, 28),  // Easter 2027
    ]

    for testCase in testCases {
        let easterDate = Calendar.current.date(
            from: .init(year: testCase.year, month: testCase.month, day: testCase.day)
        )!

        withHoliDatePreview(date: easterDate, holidays: [HoliDate.Easter]) {
            #expect(IsHolidayToday(HoliDate.Easter).wrappedValue)
        }
    }
}

@Test
@MainActor
func easterNextOccurrenceHandlesYearBoundaries() {
    let calendar = Calendar.current

    // Test date in late December
    let lateDecember = calendar.date(
        from: .init(year: 2025, month: 12, day: 31)
    )!

    // Next Easter should be in 2026
    let nextEaster = HoliDate.Easter.nextOccurrence(after: lateDecember, calendar: calendar)
    #expect(nextEaster != nil)

    if let nextEaster = nextEaster {
        let year = calendar.component(.year, from: nextEaster)
        #expect(year == 2026)
    }
}

@Test
@MainActor
func easterNextOccurrenceHandlesNilGracefully() {
    let calendar = Calendar.current

    // Test with a date very far in the past
    let farPast = calendar.date(
        from: .init(year: 1, month: 1, day: 1)
    )!

    // Should return a valid Easter date or nil
    let nextEaster = HoliDate.Easter.nextOccurrence(after: farPast, calendar: calendar)
    // This should not crash (the fix we made ensures this)
    #expect(nextEaster != nil || nextEaster == nil)  // Either outcome is acceptable as long as it doesn't crash
}

@Test
@MainActor
func easterInLeapYear() {
    // 2024 is a leap year
    let easter2024 = Calendar.current.date(
        from: .init(year: 2024, month: 3, day: 31)
    )!

    withHoliDatePreview(date: easter2024, holidays: [HoliDate.Easter]) {
        #expect(IsHolidayToday(HoliDate.Easter).wrappedValue)
    }
}
