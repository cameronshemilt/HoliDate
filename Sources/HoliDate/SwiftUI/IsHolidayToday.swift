import SwiftUI

/// Checks if a specific holiday is active today.
@propertyWrapper
@MainActor
public struct IsHolidayToday: DynamicProperty {

    private let holiday: any Holiday
    @Environment(HolidayStore.self) private var previewStore: HolidayStore?

    private var store: HolidayStore { previewStore ?? .shared }

    public init(_ holiday: any Holiday) {
        self.holiday = holiday
    }

    public var wrappedValue: Bool {
        holiday.isDuring(
            store.today,
            calendar: store.calendar
        )
    }
}
