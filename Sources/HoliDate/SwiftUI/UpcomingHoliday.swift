import SwiftUI

@propertyWrapper
@MainActor
public struct UpcomingHoliday: DynamicProperty {

    @State private var store: HolidayStore = .shared

    public init() {}

    public var wrappedValue: (any Holiday)? {
        next?.0
    }

    public var projectedValue: Date? {
        next?.1
    }

    private var next: ((any Holiday), Date)? {
        store.holidays
            .compactMap { holiday in
                holiday
                    .nextOccurrence(
                        after: store.today,
                        calendar: HoliDateEnvironment.calendar
                    )
                    .map { date in
                        (holiday, date)
                    }
            }
            .min { $0.1 < $1.1 }
    }
}
