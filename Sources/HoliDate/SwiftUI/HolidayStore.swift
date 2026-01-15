import Foundation
import Observation

@MainActor
@Observable
final class HolidayStore {

    static let shared = HolidayStore()

    private(set) var today: Date = Date()
    private(set) var holidays: [any Holiday] = []

    private init() {}

    func refresh() {
        today = HoliDateEnvironment.dateProvider.now
        holidays = HoliDateSnapshot.holidays
    }
}
