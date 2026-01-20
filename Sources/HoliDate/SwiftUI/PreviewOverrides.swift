import Foundation

@MainActor
public func withHoliDatePreview(
    date: Date,
    holidays: [any Holiday],
    calendar: Calendar = .current,
    run: () -> Void
) {
    let originalProvider = HoliDateEnvironment.dateProvider
    let originalHolidays = HoliDateSnapshot.holidays
    let originalCalendar = HoliDateEnvironment.calendar

    HoliDateEnvironment.dateProvider = PreviewDateProvider(date)
    HoliDateEnvironment.calendar = calendar
    HoliDateSnapshot.update(holidays)
    HolidayStore.shared.refresh()

    run()

    HoliDateEnvironment.dateProvider = originalProvider
    HoliDateEnvironment.calendar = originalCalendar
    HoliDateSnapshot.update(originalHolidays)
    HolidayStore.shared.refresh()
}

private struct PreviewDateProvider: DateProvider {
    let now: Date
    init(_ date: Date) { self.now = date }
}
