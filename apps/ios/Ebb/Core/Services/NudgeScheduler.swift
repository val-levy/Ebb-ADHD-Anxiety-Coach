import Foundation
import UserNotifications

/// Owns iOS notification permission and the next week's planned check-in notifications.
final class NudgeScheduler {
    private let center: UNUserNotificationCenter
    private let identifierPrefix = "planned-nudge-"

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
    }

    func reconcile(plan: [ScheduleItem], dailyCap: Int, paused: Bool, snoozedUntil: Date?) async {
        let pending = await center.pendingNotificationRequests()
        center.removePendingNotificationRequests(withIdentifiers: pending.compactMap {
            $0.identifier.hasPrefix(identifierPrefix) ? $0.identifier : nil
        })
        guard !paused, snoozedUntil.map({ $0 <= .now }) ?? true, dailyCap > 0 else { return }
        guard (try? await center.requestAuthorization(options: [.alert, .sound])) == true else { return }

        let calendar = Calendar.current
        let enabled = plan.filter(\.on)
        for dayOffset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: dayOffset, to: .now) else { continue }
            let dates = enabled.compactMap { item -> (ScheduleItem, Date)? in
                guard let date = calendar.date(bySettingHour: calendar.component(.hour, from: item.start),
                                               minute: calendar.component(.minute, from: item.start),
                                               second: 0, of: day), date > .now else { return nil }
                return (item, date)
            }
            for (item, date) in dates.sorted(by: { $0.1 < $1.1 }).prefix(dailyCap) {
                let content = UNMutableNotificationContent()
                content.title = "A gentle check-in"
                content.body = "Want a quick reset?"
                content.sound = .default
                content.userInfo = ["ebbNudge": true]
                let parts = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
                let trigger = UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)
                let request = UNNotificationRequest(identifier: "\(identifierPrefix)\(item.id.uuidString)-\(parts.year ?? 0)-\(parts.month ?? 0)-\(parts.day ?? 0)", content: content, trigger: trigger)
                try? await center.add(request)
            }
        }
    }
}
