import SwiftUI

/// Executes synchronous test code with a custom date, holidays, and calendar.
/// Use `HoliDatePreview` to render SwiftUI views with persistent overrides.
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
    let originalCalendar = HoliDateEnvironment.calendarOverride

    HoliDateEnvironment.dateProvider = PreviewDateProvider(date)
    HoliDateEnvironment.calendar = calendar
    HolidayStore.shared.update(holidays)

    defer {
        HoliDateEnvironment.dateProvider = originalProvider
        HoliDateEnvironment.calendarOverride = originalCalendar
        HolidayStore.shared.update(originalHolidays)
    }
    run()
}

private struct PreviewDateProvider: DateProvider {
    let now: Date
    init(_ date: Date) { self.now = date }
}

/// Renders content using a fixed date and an independent holiday store.
/// Overrides apply to HoliDate's SwiftUI property wrappers in this subtree.
@MainActor
public struct HoliDatePreview<Content: View>: View {
    @State private var store: HolidayStore
    private let content: Content

    public init(
        date: Date,
        holidays: [any Holiday],
        calendar: Calendar = .current,
        @ViewBuilder content: () -> Content
    ) {
        let store = HolidayStore(
            observesTimeChanges: false,
            now: { date },
            calendar: { calendar }
        )
        store.update(holidays)
        _store = State(initialValue: store)
        self.content = content()
    }

    public var body: some View {
        content.environment(store)
    }
}
