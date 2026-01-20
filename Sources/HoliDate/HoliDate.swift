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
/// Provides methods for registering holidays, checking current holidays, and managing the automatic midnight refresh scheduler.
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

    /// Registers the built-in holidays (Christmas and Easter).
    ///
    /// - Throws: `HolidayError.duplicateID` if any default holiday is already registered.
    public static func registerDefaultHolidays() async throws {
            try await HolidayRegistry.shared.register(Christmas)
            try await HolidayRegistry.shared.register(Easter)
    }

    /// Starts the automatic midnight scheduler.
    ///
    /// The scheduler automatically refreshes the holiday store at midnight each day, ensuring SwiftUI property wrappers
    /// update correctly when days change. Call once at app startup if using SwiftUI property wrappers.
    public static func startMidnightScheduler() async {
        await MidnightScheduler.shared.start()
    }

    @MainActor
    static func refreshSnapshot() async {
        let holidays = await HolidayRegistry.shared.all()
        HolidayStore.shared.update(holidays)
        HolidayStore.shared.refresh()
    }

    /// Returns all holidays that are currently active.
    ///
    /// MainActor-isolated and uses cached results for efficiency. A holiday is "current" if its `isDuring(_:calendar:)` returns true for now.
    ///
    /// - Returns: An array of holidays that are active right now.
    @MainActor
    public static func getCurrentHolidays() -> [any Holiday] {
        HolidayStore.shared.currentHolidays()
    }
}
