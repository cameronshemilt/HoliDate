import Foundation

extension Calendar {
    /// Western holidays follow Gregorian dates in the caller's time zone.
    var holidayGregorianCalendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = timeZone
        return calendar
    }
}
