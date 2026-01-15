import Foundation

actor HolidayRegistry {

    static let shared = HolidayRegistry()

    private var holidays: [String: any Holiday] = [:]

    func register(_ holiday: any Holiday) {
        holidays[holiday.id] = holiday
    }

    func deregister(id: String) {
        holidays.removeValue(forKey: id)
    }

    func all() -> [any Holiday] {
        Array(holidays.values)
    }
}
