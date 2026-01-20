import SwiftUI

/// Provides all currently active holidays.
@propertyWrapper
@MainActor
public struct CurrentHolidays: DynamicProperty {

    @State private var store: HolidayStore = HolidayStore.shared

    public init() {}

    public var wrappedValue: [any Holiday] {
        store.currentHolidays()
    }
}
