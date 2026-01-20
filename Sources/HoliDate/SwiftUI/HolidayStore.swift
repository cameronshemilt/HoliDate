import Foundation
import Observation

@MainActor
@Observable
final class HolidayStore {

    static let shared = HolidayStore()

    private(set) var holidays: [any Holiday] = []
    private(set) var today: Date = Date()

    // Cached current holidays to avoid recomputing
    private var cachedCurrentHolidays: [any Holiday] = []
    private var cacheDate: Date?

    private init() {}

    func update(_ newHolidays: [any Holiday]) {
        holidays = newHolidays
        invalidateCache()
    }

    func refresh() {
        today = HoliDateEnvironment.dateProvider.now
        invalidateCache()
    }

    private func invalidateCache() {
        cachedCurrentHolidays = []
        cacheDate = nil
    }

    public func currentHolidays() -> [any Holiday] {
        let now = HoliDateEnvironment.dateProvider.now

        // Return cached result if we've already computed for this date
        if let cacheDate, HoliDateEnvironment.calendar.isDate(now, inSameDayAs: cacheDate) {
            return cachedCurrentHolidays
        }

        // Recompute and cache
        cachedCurrentHolidays = holidays.filter {
            $0.isDuring(now, calendar: HoliDateEnvironment.calendar)
        }
        cacheDate = now

        return cachedCurrentHolidays
    }

    public func nextUpcomingHoliday(after date: Date) -> (any Holiday, Date)? {
        holidays
            .compactMap { holiday in
                holiday
                    .nextOccurrence(after: date, calendar: HoliDateEnvironment.calendar)
                    .map { (holiday, $0) }
            }
            .min { $0.1 < $1.1 }
    }
}
