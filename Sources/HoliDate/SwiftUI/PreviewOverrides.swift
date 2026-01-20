import Foundation

/// Executes a closure with a custom date, holidays, and calendar for testing or SwiftUI previews.
///
/// Temporarily overrides the HoliDate environment, executes the closure, then restores the original state.
/// Must be called on the MainActor.
///
/// - Parameters:
///   - date: The date to use as "now" within the closure.
///   - holidays: The holidays to register within the closure.
///   - calendar: The calendar to use for date calculations. Defaults to `.current`.
///   - run: The closure to execute with the overridden environment.
@MainActor
public func withHoliDatePreview(
    date: Date,
    holidays: [any Holiday],
    calendar: Calendar = .current,
    run: () -> Void
) {
    let originalProvider = HoliDateEnvironment.dateProvider
    let originalHolidays = HolidayStore.shared.holidays
    let originalCalendar = HoliDateEnvironment.calendar

    HoliDateEnvironment.dateProvider = PreviewDateProvider(date)
    HoliDateEnvironment.calendar = calendar
    HolidayStore.shared.update(holidays)
    HolidayStore.shared.refresh()

    run()

    HoliDateEnvironment.dateProvider = originalProvider
    HoliDateEnvironment.calendar = originalCalendar
    HolidayStore.shared.update(originalHolidays)
    HolidayStore.shared.refresh()
}

private struct PreviewDateProvider: DateProvider {
    let now: Date
    init(_ date: Date) { self.now = date }
}
