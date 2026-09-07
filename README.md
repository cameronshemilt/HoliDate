# HoliDate

A lightweight, Swift-native library for detecting current and upcoming holidays in a concurrency-safe, SwiftUI-friendly, and extensible way.

Built with Swift 6.2+ strict concurrency compliance.


## Requirements

- iOS 17.0+ / macOS 14.0+
- Swift 6.2+
- Xcode 16.0+

## Installation

### Swift Package Manager

Add HoliDate to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/cameronshemilt/HoliDate.git", from: "1.0.0")
]
```

Or add it through Xcode:
1. File → Add Package Dependencies
2. Enter the repository URL (`https://github.com/cameronshemilt/HoliDate`)
3. Select version requirements

## Setup

Register holidays at app startup:

```swift
import HoliDate

@main
struct MyApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .task {
                    // Register built-in holidays
                    try? await HoliDate.registerDefaultHolidays()
                }
        }
    }
}
```

## Usage

### Getting Current Holidays

**Using the property wrapper (recommended for SwiftUI):**

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

**Using the static method:**

```swift
@MainActor
func checkHolidays() {
    let holidays = HoliDate.getCurrentHolidays()
    for holiday in holidays {
        print("Today is \(holiday.name)")
    }
}
```

### Checking a Specific Holiday

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

### Getting the Next Upcoming Holiday

```swift
struct ContentView: View {
    @UpcomingHoliday private var upcomingHoliday

    var body: some View {
        if let holiday = upcomingHoliday {
            Text("Next holiday: \(holiday.name)")

            // Access the date using the projected value
            if let date = $upcomingHoliday {
                Text("On \(date.formatted())")
            }
        }
    }
}
```

## Creating Custom Holidays

Conform to the `Holiday` protocol and follow these requirements:

1. **Unique, stable ID**: Use kebab-case (e.g., "new-years-day")
2. **Singleton pattern**: Provide a static `shared` instance
3. **Use passed Calendar**: Never use `Calendar.current` - always use the `calendar` parameter

### Example: New Year's Day

```swift
import Foundation
import HoliDate

public final class NewYearsDayHoliday: Holiday {

    public static let shared = NewYearsDayHoliday()

    public let id = "new-years-day"
    public let name = "New Year's Day"

    private init() {}

    public func isDuring(_ date: Date, calendar: Calendar) -> Bool {
        let components = calendar.dateComponents([.month, .day], from: date)
        return components.month == 1 && components.day == 1
    }

    public func nextOccurrence(after date: Date, calendar: Calendar) -> Date? {
        let year = calendar.component(.year, from: date)
        guard let thisYear = calendar.date(from: .init(year: year, month: 1, day: 1)) else {
            return nil
        }

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

The registry is actor-isolated and thread-safe. Registration and deregistration automatically refresh the snapshot.

### Registering a Holiday

```swift
try await HoliDate.register(HoliDate.NewYearsDay)
```

### Deregistering a Holiday

```swift
try await HoliDate.deregister(HoliDate.NewYearsDay)
```

`registerDefaultHolidays()` registers all three built-ins atomically. If any is already
registered, it throws without adding any of the others.

## Built-in Holidays

| Holiday | API | Dates | Registered by default |
| --- | --- | --- | :---: |
| Christmas | `HoliDate.Christmas` | December 24-26, covering Christmas Eve, Christmas Day, and Boxing Day | [x] |
| Easter | `HoliDate.Easter` | Western Easter Sunday, calculated using the Computus algorithm | [x] |
| Black Friday | `HoliDate.BlackFriday` | The day after U.S. Thanksgiving, the fourth Thursday of November | [x] |

Built-ins use Gregorian dates in the supplied calendar's time zone, regardless of
the user's preferred calendar system. Custom holidays receive the original calendar
and can follow their own calendar rules.

## Previews & Testing

Use `HoliDatePreview` to give a SwiftUI preview its own fixed date and holiday store:

```swift
#Preview {
    let christmasDate = Calendar.current.date(from: .init(year: 2025, month: 12, day: 25))!

    HoliDatePreview(date: christmasDate, holidays: [HoliDate.Christmas]) {
        ContentView()
    }
}
```

Each preview keeps its overrides for its lifetime without changing other previews or the app.
Overrides apply to the SwiftUI property wrappers; static queries use the shared store.
For synchronous tests, use `withHoliDatePreview`:

```swift
import Testing
@testable import HoliDate

@Test
@MainActor
func testChristmasDetection() {
    let christmasDate = Calendar.current.date(from: .init(year: 2025, month: 12, day: 25))!

    withHoliDatePreview(date: christmasDate, holidays: [HoliDate.Christmas]) {
        #expect(IsHolidayToday(HoliDate.Christmas).wrappedValue)
    }
}
```
