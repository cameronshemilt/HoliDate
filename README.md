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
        }
        .task {
            // Register built-in holidays
            try? await HoliDate.registerDefaultHolidays()

            // Optional: Enable automatic midnight updates for SwiftUI property wrappers
            await HoliDate.startMidnightScheduler()
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
        } else {
            Text("No holidays registered")
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
do {
    try await HoliDate.register(HoliDate.NewYearsDay)
    // Snapshot is automatically refreshed - SwiftUI property wrappers update immediately
} catch HolidayError.duplicateID(let id) {
    print("Holiday \(id) is already registered")
}
```

### Deregistering a Holiday

```swift
do {
    try await HoliDate.deregister(HoliDate.NewYearsDay)
    // Snapshot is automatically refreshed
} catch HolidayError.holidayNotFound(let id) {
    print("Holiday \(id) wasn't registered")
}
```

## Built-in Holidays

HoliDate includes three built-in holidays:

- **Christmas** (`HoliDate.Christmas`): December 24-26 (Christmas Eve, Christmas Day, Boxing Day)
- **Easter** (`HoliDate.Easter`): Calculated using Computus algorithm for Western Easter
- **Black Friday** (`HoliDate.BlackFriday`): Day after U.S. Thanksgiving (4th Thursday of November)

## Previews & Testing

Use `withHoliDatePreview` to preview & test with custom dates and holidays:

```swift
#Preview {
    let christmasDate = Calendar.current.date(from: .init(year: 2025, month: 12, day: 25))!

    withHoliDatePreview(date: christmasDate, holidays: [HoliDate.Christmas]) {
        ContentView()
    }
}
```

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

## Architecture

HoliDate uses a three-layer concurrency model:

1. **Actor Layer** (`HolidayRegistry`): Thread-safe storage for registered holidays
2. **MainActor Layer** (`HolidayStore`): Cached snapshot for fast reads with automatic midnight refresh
3. **Observable Layer**: SwiftUI property wrappers with `@Observable` for reactivity

All mutations go through the actor-isolated registry, ensuring thread safety. The MainActor-isolated store provides cached, fast access for UI updates.
