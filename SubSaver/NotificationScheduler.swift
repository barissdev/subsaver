import Foundation
import UserNotifications

enum NotificationScheduler {

    // MARK: - İzin alma

    @discardableResult
    static func ensureAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()

        do {
            let settings = try await center.notificationSettings()

            switch settings.authorizationStatus {
            case .authorized, .provisional:
                return true

            case .denied:
                return false

            case .notDetermined:
                do {
                    let granted = try await center.requestAuthorization(
                        options: [.alert, .sound, .badge]
                    )
                    return granted
                } catch {
                    print("Notification auth error:", error)
                    return false
                }

            case .ephemeral:
                // Widget / App Clip gibi geçici izinler – burada bildirim planlamıyoruz
                return false

            @unknown default:
                return false
            }
        } catch {
            print("Notification settings error:", error)
            return false
        }
    }

    // MARK: - Tek bir abonelik için yenileme hatırlatması

    static func scheduleReminder(
        for sub: Subscription,
        daysBefore: Int,
        hour: Int? = nil,
        minute: Int? = nil
    ) async {
        // Bildirimler kapalıysa hiç uğraşma
        let authorized = await ensureAuthorization()
        guard authorized else { return }

        let center = UNUserNotificationCenter.current()

        // Önce bu aboneliğe ait eski bildirimi sil
        await center.removePendingNotificationRequests(withIdentifiers: [sub.id.uuidString])

        // Kaç gün önce hatırlatılacaksa tarihi ona göre hesapla
        let reminderDate = Calendar.current.date(
            byAdding: .day,
            value: -daysBefore,
            to: sub.renewalDate
        ) ?? sub.renewalDate

        var dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day],
            from: reminderDate
        )

        // Kullanıcının seçtiği saat ve dakikayı kullan
        dateComponents.hour = hour ?? sub.notifyHour
        dateComponents.minute = minute ?? sub.notifyMinute

        let content = UNMutableNotificationContent()
        content.title = String(localized: "notifications.subscriptionRenewal")
        content.body = String(format: NSLocalizedString("notifications.renewsIn", bundle: .main, comment: ""), sub.name, daysBefore)
        content.sound = .default
        content.userInfo = ["subscriptionId": sub.id.uuidString]

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: sub.id.uuidString,
            content: content,
            trigger: trigger
        )

        do {
            try await center.add(request)
        } catch {
            print("scheduleReminder error:", error)
        }
    }

    /// Eski isimle çağıran yerler için köprü (compat)
    static func scheduleRenewalReminder(
        for sub: Subscription,
        daysBefore: Int
    ) async {
        await scheduleReminder(
            for: sub,
            daysBefore: daysBefore,
            hour: sub.notifyHour,
            minute: sub.notifyMinute
        )
    }

    // MARK: - Silme fonksiyonları

    static func cancelReminder(for sub: Subscription) async {
        let center = UNUserNotificationCenter.current()
        await center.removePendingNotificationRequests(
            withIdentifiers: [sub.id.uuidString]
        )
    }

    static func cancelAll() async {
        let center = UNUserNotificationCenter.current()
        await center.removeAllPendingNotificationRequests()
    }
}
