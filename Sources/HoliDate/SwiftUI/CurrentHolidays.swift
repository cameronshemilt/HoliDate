import SwiftUI

@propertyWrapper
@MainActor
public struct CurrentHolidays: DynamicProperty {

    @State private var store: HolidayStore = HolidayStore.shared

    public init() {}

    public var wrappedValue: [any Holiday] {
        store.holidays.filter {
            $0.isDuring(
                store.today,
                calendar: .current
            )
        }
    }
}
