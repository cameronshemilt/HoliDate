import Testing
import Foundation
@testable import HoliDate

@Test
@MainActor
func blackFriday2025IsDetected() {
    // Black Friday 2025 is Nov 28
    let date = Calendar.current.date(
        from: .init(year: 2025, month: 11, day: 28)
    )!

    withHoliDatePreview(
        date: date,
        holidays: [HoliDate.BlackFriday]
    ) {
        #expect(IsHolidayToday(HoliDate.BlackFriday).wrappedValue)
    }
}

@Test
@MainActor
func blackFridayIsUpcomingAfterThanksgiving() {
    // Thanksgiving 2025 is Nov 27
    let date = Calendar.current.date(
        from: .init(year: 2025, month: 11, day: 27)
    )!

    withHoliDatePreview(
        date: date,
        holidays: [HoliDate.BlackFriday]
    ) {
        let upcoming = UpcomingHoliday()
        #expect(upcoming.wrappedValue?.id == HoliDate.BlackFriday.id)
    }
}
