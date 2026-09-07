import Foundation
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

/// Owns notification registrations and removes them when the store is released.
final class HolidayTimeObserver {
    private let center: NotificationCenter
    private let tokens: [NSObjectProtocol]

    @MainActor
    static var notificationNames: [Notification.Name] {
        var names: [Notification.Name] = [
            .NSCalendarDayChanged,
            .NSSystemClockDidChange,
            .NSSystemTimeZoneDidChange,
            NSLocale.currentLocaleDidChangeNotification
        ]
        #if canImport(UIKit)
        names += [
            UIApplication.didBecomeActiveNotification,
            UIScene.didActivateNotification,
            UIApplication.significantTimeChangeNotification
        ]
        #elseif canImport(AppKit)
        names.append(NSApplication.didBecomeActiveNotification)
        #endif
        return names
    }

    @MainActor
    init(center: NotificationCenter, refresh: @escaping @MainActor @Sendable () -> Void) {
        self.center = center
        tokens = Self.notificationNames.map { name in
            center.addObserver(forName: name, object: nil, queue: nil) { _ in
                // System notifications may arrive on any thread.
                Task { @MainActor in
                    refresh()
                }
            }
        }
    }

    deinit {
        for token in tokens {
            center.removeObserver(token)
        }
    }
}
