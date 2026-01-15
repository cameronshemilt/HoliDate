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
