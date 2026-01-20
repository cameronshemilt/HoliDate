import SwiftUI

/// Checks if a specific holiday is active today.
@propertyWrapper
@MainActor
public struct IsHolidayToday: DynamicProperty {

    private let holiday: any Holiday
    @State private var store: HolidayStore = HolidayStore.shared

    public init(_ holiday: any Holiday) {
        self.holiday = holiday
    }

    public var wrappedValue: Bool {
        holiday.isDuring(
            store.today,
            calendar: HoliDateEnvironment.calendar
        )
    }
}
