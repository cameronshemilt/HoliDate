import Foundation
import Observation
import Testing
import XCTest
@testable import HoliDate

@MainActor
private final class TestClock {
    var date: Date
    var calendar: Calendar

    init() {
        calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        date = calendar.date(from: .init(year: 2025, month: 12, day: 23, hour: 12))!
    }
}

@Test
@MainActor
func systemEventsRefreshDateAndHolidayResults() async {
    // Each store has its own center and clock, so these tests never change the
    // global preview environment while suspended.
    for name in HolidayTimeObserver.notificationNames {
        let center = NotificationCenter()
        let clock = TestClock()
        let store = HolidayStore(notificationCenter: center, now: { clock.date }, calendar: { clock.calendar })
        store.update([HoliDate.Christmas])
        #expect(store.currentHolidays().isEmpty)
        let firstOccurrence = store.nextUpcomingHoliday(after: store.today)?.1

        let changed = XCTestExpectation(description: "Refresh for \(name.rawValue)")
        withObservationTracking {
            _ = store.currentHolidays()
        } onChange: {
            changed.fulfill()
        }

        clock.date = clock.calendar.date(from: .init(year: 2025, month: 12, day: 25, hour: 12))!
        // Exercise delivery from outside the main actor too.
        await Task.detached {
            center.post(name: name, object: nil)
        }.value
        let result = await XCTWaiter.fulfillment(of: [changed], timeout: 2)
        #expect(result == .completed)
        #expect(store.today == clock.date)
        #expect(store.currentHolidays().map(\.id) == ["christmas"])
        #expect(store.holidays.map(\.id) == ["christmas"])
        #expect(store.nextUpcomingHoliday(after: store.today)?.1 != firstOccurrence)
    }
}

@Test
@MainActor
func timeZoneChangeRecomputesHolidaysWithoutChangingTheInstant() async {
    let center = NotificationCenter()
    let clock = TestClock()
    clock.date = clock.calendar.date(from: .init(year: 2025, month: 12, day: 24, hour: 1))!
    let store = HolidayStore(notificationCenter: center, now: { clock.date }, calendar: { clock.calendar })
    store.update([HoliDate.Christmas])
    #expect(store.currentHolidays().count == 1)

    let changed = XCTestExpectation(description: "Calendar refresh")
    withObservationTracking {
        _ = store.calendar
    } onChange: {
        changed.fulfill()
    }
    clock.calendar.timeZone = TimeZone(identifier: "America/Los_Angeles")!
    center.post(name: .NSSystemTimeZoneDidChange, object: nil)
    let result = await XCTWaiter.fulfillment(of: [changed], timeout: 2)
    #expect(result == .completed)
    #expect(store.today == clock.date)
    #expect(store.calendar.timeZone == clock.calendar.timeZone)
    #expect(store.currentHolidays().isEmpty)
}

@Test
@MainActor
func explicitQueryRefreshesAllWrappersWithoutNotification() {
    let clock = TestClock()
    withHoliDatePreview(date: clock.date, holidays: [HoliDate.Christmas], calendar: clock.calendar) {
        #expect(CurrentHolidays().wrappedValue.isEmpty)
        #expect(!IsHolidayToday(HoliDate.Christmas).wrappedValue)
        let previousUpcomingDate = UpcomingHoliday().projectedValue

        struct FixedDate: DateProvider { let now: Date }
        let christmas = clock.calendar.date(from: .init(year: 2025, month: 12, day: 25, hour: 12))!
        HoliDateEnvironment.dateProvider = FixedDate(now: christmas)

        #expect(HoliDate.getCurrentHolidays().map(\.id) == ["christmas"])
        #expect(CurrentHolidays().wrappedValue.map(\.id) == ["christmas"])
        #expect(IsHolidayToday(HoliDate.Christmas).wrappedValue)
        #expect(UpcomingHoliday().projectedValue != previousUpcomingDate)
    }
}

@Test
@MainActor
func previewRestoresAutomaticCalendarAndNestedOverrides() {
    let originalOverride = HoliDateEnvironment.calendarOverride
    defer { HoliDateEnvironment.calendarOverride = originalOverride }
    HoliDateEnvironment.calendarOverride = nil
    let clock = TestClock()
    withHoliDatePreview(date: clock.date, holidays: [], calendar: clock.calendar) {
        var otherCalendar = clock.calendar
        otherCalendar.timeZone = TimeZone(identifier: "Asia/Tokyo")!
        withHoliDatePreview(date: clock.date, holidays: [], calendar: otherCalendar) {
            HolidayStore.shared.refresh()
            #expect(HolidayStore.shared.calendar.timeZone == otherCalendar.timeZone)
        }
        #expect(HoliDateEnvironment.calendar == clock.calendar)
    }
    #expect(HoliDateEnvironment.calendarOverride == nil)
}

@Test
@MainActor
func notificationObserversDoNotRetainTheStore() {
    let center = NotificationCenter()
    var store: HolidayStore? = HolidayStore(notificationCenter: center)
    weak var weakStore: HolidayStore?
    weakStore = store
    #expect(weakStore != nil)
    store = nil
    #expect(weakStore == nil)
}

@Test
@MainActor
func checkingTheSameDayDoesNotInvalidateViews() {
    let clock = TestClock()
    let store = HolidayStore(notificationCenter: NotificationCenter(), now: { clock.date }, calendar: { clock.calendar })
    store.update([HoliDate.Christmas])
    withObservationTracking {
        _ = store.today
        _ = store.calendar
        _ = store.currentHolidays()
    } onChange: {
        Issue.record("An unchanged day must not invalidate views on every explicit query")
    }
    clock.date = clock.date.addingTimeInterval(60)
    store.refreshIfNeeded()
    store.refreshIfNeeded()
}
