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
