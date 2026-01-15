import Foundation

@MainActor
public func withHoliDatePreview(
    date: Date,
    holidays: [any Holiday],
    run: () -> Void
) {
    let originalProvider = HoliDateEnvironment.dateProvider
    let originalHolidays = HoliDateSnapshot.holidays

    HoliDateEnvironment.dateProvider = PreviewDateProvider(date)
    HoliDateSnapshot.update(holidays)
    HolidayStore.shared.refresh()

    run()

    HoliDateEnvironment.dateProvider = originalProvider
    HoliDateSnapshot.update(originalHolidays)
    HolidayStore.shared.refresh()
}

private struct PreviewDateProvider: DateProvider {
    let now: Date
    init(_ date: Date) { self.now = date }
}
