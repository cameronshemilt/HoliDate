import SwiftUI

/// Provides the next upcoming holiday.
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
        store.nextUpcomingHoliday(after: store.today)
    }
}
