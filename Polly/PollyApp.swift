//
//  PollyApp.swift
//  Polly
//

import SwiftUI
import SwiftData

@main
struct PollyApp: App {
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var entitlementManager = EntitlementManager.shared

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Policy.self,
            PolicyCostRecord.self,
            PolicyDocument.self,
            Driver.self,
            Vehicle.self,
            InsuredProperty.self,
        ])

        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(notificationManager)
                .environmentObject(entitlementManager)
                .task {
                    await notificationManager.requestPermission()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
