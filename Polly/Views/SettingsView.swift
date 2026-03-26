//
//  SettingsView.swift
//  Polly
//

import SwiftUI
import SwiftData
import UserNotifications

struct SettingsView: View {
    @EnvironmentObject private var notificationManager: NotificationManager
    @Environment(\.modelContext) private var modelContext
    @State private var showingTestConfirmation = false
    @State private var showingDeleteConfirmation = false

    var body: some View {
        NavigationStack {
            Form {
                // MARK: - Notifications
                Section {
                    HStack {
                        Label("Notifications", systemImage: "bell.fill")
                        Spacer()
                        Text(notificationManager.permissionGranted ? "Enabled" : "Disabled")
                            .foregroundStyle(notificationManager.permissionGranted ? .green : .red)
                            .font(.subheadline)
                    }
                    if !notificationManager.permissionGranted {
                        Button("Enable Notifications") {
                            Task {
                                await notificationManager.requestPermission()
                            }
                        }
                    }
                } header: {
                    Text("Notifications")
                } footer: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Polly uses notifications to remind you before policies renew.")
                        if !notificationManager.permissionGranted {
                            Button("Open Notification Settings") {
                                #if os(macOS)
                                if let url = URL(string: "x-apple.systempreferences:com.apple.preference.notifications") {
                                    NSWorkspace.shared.open(url)
                                }
                                #else
                                if let url = URL(string: UIApplication.openSettingsURLString) {
                                    UIApplication.shared.open(url)
                                }
                                #endif
                            }
                            .font(.footnote)
                        }
                    }
                }

                // MARK: - Debug
                #if DEBUG
                Section {
                    Button {
                        scheduleTestNotification()
                        showingTestConfirmation = true
                    } label: {
                        Label("Send Test Notification", systemImage: "bell.badge")
                    }
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete All Data", systemImage: "trash")
                    }
                } header: {
                    Text("Debug")
                } footer: {
                    Text("Sends a test notification in 10 seconds. Background the app to see it.")
                }
                #endif

                // MARK: - About
                Section("About") {
                    LabeledContent("App", value: "Polly")
                    LabeledContent("Version", value: appVersion)
                }
            }
            .navigationTitle("Settings")
            .alert("Test Notification Scheduled", isPresented: $showingTestConfirmation) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Background the app now. A notification will arrive in 10 seconds.")
            }
            #if DEBUG
            .confirmationDialog(
                "Delete All Data?",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete Everything", role: .destructive) { deleteAllData() }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text("This will permanently delete all policies, documents, and history. This cannot be undone.")
            }
            #endif
        }
    }

    // MARK: - App Version

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    // MARK: - Delete All Data

    #if DEBUG
    private func deleteAllData() {
        try? modelContext.delete(model: Policy.self)
        try? modelContext.delete(model: PolicyCostRecord.self)
        try? modelContext.delete(model: PolicyDocument.self)
        try? modelContext.delete(model: Driver.self)
        try? modelContext.delete(model: Vehicle.self)
        try? modelContext.delete(model: InsuredProperty.self)
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    #endif

    // MARK: - Test Notification

    private func scheduleTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Polly Test Notification"
        content.body = "Notifications are working correctly."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 10,
            repeats: false
        )

        let request = UNNotificationRequest(
            identifier: "polly.test.notification",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("Test notification error: \(error)")
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(NotificationManager.shared)
}
