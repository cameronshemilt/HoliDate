import Foundation

actor HolidayRegistry {

    static let shared = HolidayRegistry()

    private var holidays: [String: any Holiday] = [:]

    func register(_ holiday: any Holiday) async throws {
        try await register([holiday])
    }

    /// Validates the entire batch before committing or publishing any changes.
    func register(_ newHolidays: [any Holiday]) async throws {
        var ids = Set(holidays.keys)
        for holiday in newHolidays {
            guard ids.insert(holiday.id).inserted else {
                throw HolidayError.duplicateID(holiday.id)
            }
        }
        for holiday in newHolidays {
            holidays[holiday.id] = holiday
        }
        await HoliDate.refreshSnapshot()
    }

    func deregister(_ holiday: any Holiday) async throws {
        guard holidays.removeValue(forKey: holiday.id) != nil else {
            throw HolidayError.holidayNotFound(holiday.id)
        }
        await HoliDate.refreshSnapshot()
    }

    func all() -> [any Holiday] {
        Array(holidays.values)
    }
}
