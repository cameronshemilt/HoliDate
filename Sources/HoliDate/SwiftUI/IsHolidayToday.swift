import SwiftUI

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
            calendar: .current
        )
    }
}
