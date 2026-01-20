import Foundation

actor HolidayRegistry {

    static let shared = HolidayRegistry()

    private var holidays: [String: any Holiday] = [:]

    func register(_ holiday: any Holiday) throws {
        if holidays[holiday.id] != nil {
            throw HolidayError.duplicateID(holiday.id)
        }
        holidays[holiday.id] = holiday
        Task { @MainActor in
            await HoliDate.refreshSnapshot()
        }
    }

    func deregister(_ holiday: any Holiday) throws {
        guard holidays.removeValue(forKey: holiday.id) != nil else {
            throw HolidayError.holidayNotFound(holiday.id)
        }
        Task { @MainActor in
            await HoliDate.refreshSnapshot()
        }
    }

    func all() -> [any Holiday] {
        Array(holidays.values)
    }
}
