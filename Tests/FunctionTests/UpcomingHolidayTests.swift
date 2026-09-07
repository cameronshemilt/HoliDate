import Testing
import Foundation
@testable import HoliDate

@Test
@MainActor
func upcomingHolidayIsEaster() {
    let date = Calendar.current.date(
        from: .init(year: 2025, month: 4, day: 1)
    )!

    withHoliDatePreview(
        date: date,
        holidays: [HoliDate.Easter, HoliDate.Christmas]
    ) {
        let upcoming = UpcomingHoliday()
        #expect(upcoming.wrappedValue?.id == HoliDate.Easter.id)
    }
}


