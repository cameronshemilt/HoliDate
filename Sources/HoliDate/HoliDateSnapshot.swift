import Foundation

@MainActor
public enum HoliDateSnapshot {

    static var holidays: [any Holiday] = []

    static func update(_ newValue: [any Holiday]) {
        holidays = newValue
    }

    public static func currentHolidays() -> [any Holiday] {
        let now = HoliDateEnvironment.dateProvider.now
        return holidays.filter {
            $0.isDuring(now, calendar: HoliDateEnvironment.calendar)
        }
    }

    static func nextUpcomingHoliday(
        after date: Date
    ) -> (any Holiday, Date)? {
        holidays
            .compactMap { holiday in
                holiday
                    .nextOccurrence(after: date, calendar: HoliDateEnvironment.calendar)
                    .map { (holiday, $0) }
            }
            .min { $0.1 < $1.1 }
    }
}
