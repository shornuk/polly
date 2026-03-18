//
//  NotificationManager.swift
//  Polly
//

import Foundation
import UserNotifications
import Combine

class NotificationManager: ObservableObject {

    static let shared = NotificationManager()

    @MainActor @Published var permissionGranted = false

    private init() {}

    // MARK: - Permission

    func requestPermission() async {
        do {
            let granted = try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound])
            permissionGranted = granted
        } catch {
            print("Notification permission error: \(error)")
        }
    }

    func checkPermissionStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        permissionGranted = settings.authorizationStatus == .authorized
    }

    // MARK: - Schedule

    func scheduleReminder(for policy: Policy) {
        guard policy.reminderEnabled,
              let renewalDate = policy.renewalDate else { return }

        // Cancel any existing notification for this policy
        cancelReminder(for: policy)

        // Calculate trigger date
        let triggerDate = Calendar.current.date(
            byAdding: .day,
            value: -policy.reminderDaysBefore,
            to: renewalDate
        ) ?? renewalDate

        // Don't schedule if trigger date is in the past
        guard triggerDate > Date() else { return }

        let content = UNMutableNotificationContent()
        content.title = reminderTitle(for: policy)
        content.body = reminderBody(for: policy)
        content.sound = .default
        content.badge = 1

        // Store policy ID in userInfo for handling taps
        content.userInfo = ["policyID": policy.id.uuidString]

        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: triggerDate
        )

        let trigger = UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: notificationID(for: policy),
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }

    // MARK: - Cancel

    func cancelReminder(for policy: Policy) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(
                withIdentifiers: [notificationID(for: policy)]
            )
    }

    // MARK: - Reschedule All

    func rescheduleAll(policies: [Policy]) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        for policy in policies where policy.isActive {
            scheduleReminder(for: policy)
        }
    }

    // MARK: - Helpers

    private func notificationID(for policy: Policy) -> String {
        "polly.reminder.\(policy.id.uuidString)"
    }

    private func reminderTitle(for policy: Policy) -> String {
        if policy.reminderDaysBefore == 0 {
            return "\(policy.displayName) renews today"
        }
        return "\(policy.displayName) renews soon"
    }

    private func reminderBody(for policy: Policy) -> String {
        guard let renewalDate = policy.renewalDate else { return "" }

        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none

        let dateString = formatter.string(from: renewalDate)

        if policy.reminderDaysBefore == 1 {
            return "Your \(policy.category.rawValue.lowercased()) policy renews tomorrow (\(dateString))."
        }
        return "Your \(policy.category.rawValue.lowercased()) policy with \(policy.provider) renews on \(dateString). Time to review your options."
    }
}
