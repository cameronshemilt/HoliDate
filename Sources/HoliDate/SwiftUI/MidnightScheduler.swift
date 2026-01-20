import Foundation

actor MidnightScheduler {

    static let shared = MidnightScheduler()
    private var task: Task<Void, Never>?

    func start() {
        task?.cancel()

        task = Task {
            while !Task.isCancelled {
                let now = Date()
                let calendar = await MainActor.run { HoliDateEnvironment.calendar }

                guard let nextMidnight = calendar.nextDate(
                    after: now,
                    matching: DateComponents(hour: 0, minute: 0, second: 0),
                    matchingPolicy: .nextTime
                ) else { return }

                let interval = nextMidnight.timeIntervalSince(now)
                try? await Task.sleep(for: .seconds(interval))

                await HoliDate.refreshSnapshot()
            }
        }
    }
}
