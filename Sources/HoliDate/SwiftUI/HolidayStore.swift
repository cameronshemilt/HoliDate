import Foundation
import Observation

@MainActor
@Observable
final class HolidayStore {

    static let shared = HolidayStore()

    private(set) var holidays: [any Holiday] = []
    private(set) var today: Date
    private(set) var calendar: Calendar
    private var cachedCurrentHolidays: [any Holiday] = []

    @ObservationIgnored private let now: () -> Date
    @ObservationIgnored private let currentCalendar: () -> Calendar
    @ObservationIgnored private var timeObserver: HolidayTimeObserver?

    init(
        notificationCenter: NotificationCenter = .default,
        now: @escaping () -> Date = { HoliDateEnvironment.dateProvider.now },
        calendar: @escaping () -> Calendar = { HoliDateEnvironment.calendar }
    ) {
        self.now = now
        self.currentCalendar = calendar
        self.today = now()
        self.calendar = calendar()
        timeObserver = HolidayTimeObserver(center: notificationCenter) { [weak self] in
            self?.refresh()
        }
    }

    func update(_ newHolidays: [any Holiday]) {
        holidays = newHolidays
        refresh()
    }

    func refreshIfNeeded() {
        let calendar = currentCalendar()
        guard calendar != self.calendar || !calendar.isDate(now(), inSameDayAs: today) else {
            return
        }
        refresh()
    }

    func refresh() {
        today = now()
        calendar = currentCalendar()
        cachedCurrentHolidays = holidays.filter {
            $0.isDuring(today, calendar: calendar)
        }
    }

    func currentHolidays() -> [any Holiday] {
        cachedCurrentHolidays
    }

    func nextUpcomingHoliday(after date: Date) -> (any Holiday, Date)? {
        holidays
            .compactMap { holiday in
                holiday
                    .nextOccurrence(after: date, calendar: calendar)
                    .map { (holiday, $0) }
            }
            .min { $0.1 < $1.1 }
    }
}
