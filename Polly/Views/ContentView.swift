//
//  ContentView.swift
//  Polly
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                DashboardView()
            }

            Tab("Policies", systemImage: "list.bullet.rectangle.fill") {
                PoliciesListView()
            }

            Tab("Insights", systemImage: "chart.bar.fill") {
                Text("Insights coming soon")
            }

            Tab("Settings", systemImage: "gearshape.fill") {
                SettingsView()
            }
        }
    }
}

#Preview {
    ContentView()
}
