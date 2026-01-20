import Testing
import Foundation
@testable import HoliDate

@Test
@MainActor
func registryThrowsOnDuplicateID() async throws {
    // Create a test holiday
    final class TestHoliday: Holiday {
        static let shared = TestHoliday()
        let id = "test-duplicate-holiday"
        let name = "Test Holiday"
        private init() {}

        func isDuring(_ date: Date, calendar: Calendar) -> Bool { false }
        func nextOccurrence(after date: Date, calendar: Calendar) -> Date? { nil }
    }

    // Register the holiday once - should succeed
    try await HolidayRegistry.shared.register(TestHoliday.shared)

    // Try to register again - should throw
    await #expect(throws: HolidayError.duplicateID("test-duplicate-holiday")) {
        try await HolidayRegistry.shared.register(TestHoliday.shared)
    }

    // Cleanup
    try await HolidayRegistry.shared.deregister(TestHoliday.shared)
}

@Test
@MainActor
func registryThrowsOnDeregisterNonExistent() async throws {
    // Create a test holiday that was never registered
    final class UnregisteredHoliday: Holiday {
        static let shared = UnregisteredHoliday()
        let id = "never-registered-holiday"
        let name = "Unregistered Holiday"
        private init() {}

        func isDuring(_ date: Date, calendar: Calendar) -> Bool { false }
        func nextOccurrence(after date: Date, calendar: Calendar) -> Date? { nil }
    }

    // Try to deregister - should throw
    await #expect(throws: HolidayError.holidayNotFound("never-registered-holiday")) {
        try await HolidayRegistry.shared.deregister(UnregisteredHoliday.shared)
    }
}

@Test
@MainActor
func automaticSnapshotRefreshAfterRegistration() async throws {
    // Create a test holiday with a unique ID
    final class AutoRefreshTestHoliday: Holiday {
        static let shared = AutoRefreshTestHoliday()
        let id = "auto-refresh-test-holiday-unique-\(UUID().uuidString)"
        let name = "Auto Refresh Test"
        private init() {}

        func isDuring(_ date: Date, calendar: Calendar) -> Bool { true }
        func nextOccurrence(after date: Date, calendar: Calendar) -> Date? { nil }
    }

    // Verify holiday is not in snapshot before registration
    let beforeHolidays = HoliDate.getCurrentHolidays()
    #expect(!beforeHolidays.contains { $0.id == AutoRefreshTestHoliday.shared.id })

    // Register the holiday
    try await HolidayRegistry.shared.register(AutoRefreshTestHoliday.shared)

    // Verify the snapshot was automatically updated and now contains our holiday
    let afterHolidays = HoliDate.getCurrentHolidays()
    #expect(afterHolidays.contains { $0.id == AutoRefreshTestHoliday.shared.id })

    // Cleanup
    try await HolidayRegistry.shared.deregister(AutoRefreshTestHoliday.shared)

    // Verify cleanup worked
    let cleanupHolidays = HoliDate.getCurrentHolidays()
    #expect(!cleanupHolidays.contains { $0.id == AutoRefreshTestHoliday.shared.id })
}

@Test
@MainActor
func deregisterRemovesHolidayAndRefreshesSnapshot() async throws {
    // Create a test holiday with a unique ID
    final class DeregisterTestHoliday: Holiday {
        static let shared = DeregisterTestHoliday()
        let id = "deregister-test-holiday-unique-\(UUID().uuidString)"
        let name = "Deregister Test"
        private init() {}

        func isDuring(_ date: Date, calendar: Calendar) -> Bool { true }
        func nextOccurrence(after date: Date, calendar: Calendar) -> Date? { nil }
    }

    // Register the holiday
    try await HolidayRegistry.shared.register(DeregisterTestHoliday.shared)

    // Verify our holiday is in the snapshot after registration
    let beforeHolidays = HoliDate.getCurrentHolidays()
    #expect(beforeHolidays.contains { $0.id == DeregisterTestHoliday.shared.id })

    // Deregister the holiday
    try await HolidayRegistry.shared.deregister(DeregisterTestHoliday.shared)

    // Verify the snapshot was automatically updated and no longer contains our holiday
    let afterHolidays = HoliDate.getCurrentHolidays()
    #expect(!afterHolidays.contains { $0.id == DeregisterTestHoliday.shared.id })
}
