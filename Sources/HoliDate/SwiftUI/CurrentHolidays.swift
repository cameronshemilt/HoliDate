import SwiftUI

/// Provides all currently active holidays.
@propertyWrapper
@MainActor
public struct CurrentHolidays: DynamicProperty {

    @Environment(HolidayStore.self) private var previewStore: HolidayStore?

    private var store: HolidayStore { previewStore ?? .shared }

    public init() {}

    public var wrappedValue: [any Holiday] {
        store.currentHolidays()
    }
}
