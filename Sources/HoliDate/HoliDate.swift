import Foundation

public enum HoliDate {

    public static func registerDefaultHolidays() async {
            await HolidayRegistry.shared.register(Christmas)
            await HolidayRegistry.shared.register(Easter)
            await refreshSnapshot()
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
