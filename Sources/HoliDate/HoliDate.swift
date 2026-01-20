import Foundation

public enum HolidayError: Error, Sendable, Equatable {
    case duplicateID(String)
    case holidayNotFound(String)
}

public enum HoliDate {

    public static func register(_ holiday: any Holiday) async throws {
        try await HolidayRegistry.shared.register(holiday)
    }

    public static func deregister(_ holiday: any Holiday) async throws {
        try await HolidayRegistry.shared.deregister(holiday)
    }

    public static func registerDefaultHolidays() async throws {
            try await HolidayRegistry.shared.register(Christmas)
            try await HolidayRegistry.shared.register(Easter)
    }

    public static func startMidnightScheduler() async {
        await MidnightScheduler.shared.start()
    }

    @MainActor
    static func refreshSnapshot() async {
        let holidays = await HolidayRegistry.shared.all()
        HoliDateSnapshot.update(holidays)
        HolidayStore.shared.refresh()
    }

    public static func getCurrentHolidays() async -> [any Holiday] {
        await MainActor.run {
            HoliDateSnapshot.currentHolidays()
        }
    }
}
