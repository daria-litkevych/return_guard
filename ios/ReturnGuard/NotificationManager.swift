import Foundation
import UserNotifications

/// Schedules the app's fixed reminder rule (see the design's "Notifications"
/// turn): 7 days before a return deadline, and again 1 day before, both at
/// 9am local time, for purchases still inside their return window. Silent
/// on the day the window actually closes — that state only ever shows
/// in-app (Home/Warranties), never as a push.
enum NotificationManager {
    static let notificationsEnabledKey = "notificationsEnabled"
    private static let idPrefix = "returnguard."

    static var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: notificationsEnabledKey)
    }

    /// Requests permission if not yet determined. Returns whether alerts are
    /// authorized afterward, so callers can reflect a denial in their UI.
    @discardableResult
    static func requestAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .denied:
            return false
        case .notDetermined:
            return (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        @unknown default:
            return false
        }
    }

    /// Clears every ReturnGuard-scheduled reminder, then — if notifications
    /// are enabled and actually authorized — reschedules the 7-day/1-day
    /// reminders for every purchase still returnable. Cheap enough to call
    /// any time the purchase list changes; safe to call repeatedly.
    static func syncReminders(for purchases: [Purchase]) {
        let center = UNUserNotificationCenter.current()
        center.getPendingNotificationRequests { requests in
            let ours = requests.map(\.identifier).filter { $0.hasPrefix(idPrefix) }
            if !ours.isEmpty {
                center.removePendingNotificationRequests(withIdentifiers: ours)
            }

            guard isEnabled else { return }
            center.getNotificationSettings { settings in
                guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else {
                    return
                }
                for purchase in purchases where purchase.isReturnable {
                    schedule(for: purchase, center: center)
                }
            }
        }
    }

    private static func schedule(for purchase: Purchase, center: UNUserNotificationCenter) {
        scheduleOne(id: "\(idPrefix)\(purchase.id.uuidString).7day", purchase: purchase,
                    daysBefore: 7, body: "Your return window closes in 7 days.", center: center)
        scheduleOne(id: "\(idPrefix)\(purchase.id.uuidString).1day", purchase: purchase,
                    daysBefore: 1, body: "Your return window closes tomorrow.", center: center)
    }

    private static func scheduleOne(id: String, purchase: Purchase, daysBefore: Int, body: String,
                                     center: UNUserNotificationCenter) {
        let calendar = Calendar.current
        guard let fireDay = calendar.date(byAdding: .day, value: -daysBefore, to: purchase.returnDeadline) else {
            return
        }
        var components = calendar.dateComponents([.year, .month, .day], from: fireDay)
        components.hour = 9
        components.minute = 0

        guard let fireDate = calendar.date(from: components), fireDate > Date() else {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = purchase.product
        content.body = body
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        center.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
    }
}
