#  HoliDate
HoliDate is a lightweight, Swift-native library for detecting current and upcoming holidays in a concurrency-safe, SwiftUI-friendly, and extensible way.

## Installation

## Setup

```swift
import HoliDate

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .task {
            await HoliDate.registerDefaultHolidays()
        }
}
    }
}

```

If you want the SwiftUI property wrappers to automatically update after midnight, you have to additionally call `startMidnightScheduler()`.

## Usage

### Getting the current holidays
```swift
    let holidays = await HoliDate.getCurrentHolidays()
```

Or use the SwiftUI property wrapper.
```swift
struct ContentView: View {
    @CurrentHolidays private var holidays

    var body: some View {
        List(holidays, id: \.id) { holiday in
            Text(holiday.name)
        }
    }
}

```

### Checking a specific holiday
```swift
struct ContentView: View {
    @IsHolidayToday(HoliDate.Christmas) private var isChristmas

    var body: some View {
        if isChristmas {
            Text("🎄 Merry Christmas!")
        } else {
            Text("Not Christmas quite yet")
        }
    }
}

```

### Getting the next upcoming holiday
```swift
struct ContentView: View {
    @UpcomingHoliday private var upcomingHoliday

    var body: some View {
        if let holiday = upcomingHoliday {
            Text("Next holiday: \(upcomingHoliday.name)")
            
            // Access the upcoming date using the projected value
            if let date = $holiday {
                Text("On \(date.formatted())")
            }
        } else {
            Text("No holidays registered")
        }
    }
}

```

## Creating custom holidays
To create a custom holiday, conform to the `Holiday` protocol.

All holidays should:
1. Have a **stable** & **unique** `id`.
2. Use the **passed** `Calendar` for all calculations.

> Note:
> Don't forget to *Register* your holidays

**Example: New Years Day**
```swift
import Foundation
import HoliDate

public final class NewYearsDayHoliday: Holiday {

    public static let shared = NewYearsDayHoliday()

    public let id = "new-years-day"
    public let name = "New Year’s Day"

    private init() {}

    public func isDuring(_ date: Date, calendar: Calendar) -> Bool {
        let components = calendar.dateComponents([.month, .day], from: date)
        return components.month == 1 && components.day == 1
    }

    public func nextOccurrence(
        after date: Date,
        calendar: Calendar
    ) -> Date? {
        let year = calendar.component(.year, from: date)
        let thisYear = calendar.date(
            from: .init(year: year, month: 1, day: 1)
        )!

        return thisYear > date
            ? thisYear
            : calendar.date(from: .init(year: year + 1, month: 1, day: 1))
    }
}

extension HoliDate {
    public static let NewYearsDay = NewYearsDayHoliday.shared
}

```

## Registering & Deregistering Holidays
HoliDate uses an actor-isolated registry, so all mutations are async and safe.

### Registering a holiday
```swift
await HolidayRegistry.shared.register(NewYearsDayHoliday.shared)
await HoliDate.refreshSnapshot()
```

### Deregistering a holiday
```swift
await HolidayRegistry.shared.deregister(NewYearsDayHoliday.shared)
await HoliDate.refreshSnapshot()
```
