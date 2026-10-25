import Foundation
import UserNotifications

enum ReminderService {
    static func requestAccess() async -> Bool {
        (try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])) ?? false
    }
    static func reschedule(records: [ShiftRecord], kinds: [ShiftKind], settings: NurseSettings) async {
        let center = UNUserNotificationCenter.current()
        let prior = await center.pendingNotificationRequests().filter { $0.identifier.hasPrefix("nurseflow-shift-") }
        center.removePendingNotificationRequests(withIdentifiers: prior.map(\.identifier))
        guard settings.notifyEnabled else { return }
        let now = Date()
        for item in records.sorted(by: { $0.day < $1.day }) {
            guard let kind = kinds.first(where: { $0.id == item.kindID }),
                  let interval = ScheduleMath.interval(item, kind: kind) else { continue }
            let reminder = interval.start.addingTimeInterval(-Double(settings.notificationLeadMinutes * 60))
            guard reminder > now, reminder < now.addingTimeInterval(60*60*24*60) else { continue }
            let content = UNMutableNotificationContent()
            content.title = "ใกล้เวลาเข้า\(kind.title)"
            content.body = "\(item.day) • \(kind.code) — เตรียมตัวก่อนเข้าเวร"
            content.sound = .default
            let dateParts = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: reminder)
            try? await center.add(UNNotificationRequest(identifier: "nurseflow-shift-\(item.day)", content: content, trigger: UNCalendarNotificationTrigger(dateMatching: dateParts, repeats: false)))
        }
    }
}
