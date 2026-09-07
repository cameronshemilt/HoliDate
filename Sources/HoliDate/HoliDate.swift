import Foundation

/// Errors that can occur during holiday registration and deregistration.
public enum HolidayError: Error, Sendable, Equatable {
    /// Thrown when attempting to register a holiday with an ID that's already registered.
    case duplicateID(String)

    /// Thrown when attempting to deregister a holiday that isn't registered.
    case holidayNotFound(String)
}

/// The main API for working with holidays in HoliDate.
///
/// Registers and checks holidays, with automatic updates when the date or app activity changes.
public enum HoliDate {

    /// Registers a holiday in the global registry.
    ///
    /// Automatically refreshes the snapshot, ensuring SwiftUI property wrappers immediately reflect the change.
    ///
    /// - Parameter holiday: The holiday to register.
    /// - Throws: `HolidayError.duplicateID` if a holiday with the same ID is already registered.
    public static func register(_ holiday: any Holiday) async throws {
        try await HolidayRegistry.shared.register(holiday)
    }

    /// Removes a holiday from the global registry.
    ///
    /// Automatically refreshes the snapshot, ensuring SwiftUI property wrappers immediately reflect the change.
    ///
    /// - Parameter holiday: The holiday to deregister.
    /// - Throws: `HolidayError.holidayNotFound` if the holiday isn't registered.
    public static func deregister(_ holiday: any Holiday) async throws {
        try await HolidayRegistry.shared.deregister(holiday)
    }

    /// Registers Christmas, Easter, and Black Friday as one atomic batch.
    /// If any is already registered, the registry remains unchanged.
    ///
    /// - Throws: `HolidayError.duplicateID` if any default holiday is already registered.
    public static func registerDefaultHolidays() async throws {
        try await HolidayRegistry.shared.register([Christmas, Easter, BlackFriday])
    }

    /// Updates start automatically when the holiday store is first used.
    @available(*, deprecated, message: "Holiday updates are automatic; this call is no longer needed.")
    public static func startMidnightScheduler() async {
        await HolidayStore.shared.refresh()
    }

    @MainActor
    static func refreshSnapshot() async {
        let holidays = await HolidayRegistry.shared.all()
        HolidayStore.shared.update(holidays)
    }

    /// Returns all holidays that are currently active.
    ///
    /// MainActor-isolated. Checks the current day and calendar on each call and refreshes
    /// cached results when either changes. A holiday is "current" if its `isDuring(_:calendar:)` returns true.
    ///
    /// - Returns: An array of holidays that are active right now.
    @MainActor
    public static func getCurrentHolidays() -> [any Holiday] {
        // Explicit queries use the current clock even before a notification arrives.
        HolidayStore.shared.refreshIfNeeded()
        return HolidayStore.shared.currentHolidays()
    }
}
