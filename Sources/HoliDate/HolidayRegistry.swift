import Foundation

actor HolidayRegistry {

    static let shared = HolidayRegistry()

    private var holidays: [String: any Holiday] = [:]

    func register(_ holiday: any Holiday) async throws {
        if holidays[holiday.id] != nil {
            throw HolidayError.duplicateID(holiday.id)
        }
        holidays[holiday.id] = holiday
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
