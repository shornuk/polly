//
//  PoliciesListView.swift
//  Polly
//

import SwiftUI
import SwiftData

struct PoliciesListView: View {
    @State private var showingAddSheet = false
    @Environment(\.modelContext) private var modelContext
    @Query private var allPolicies: [Policy]

    private var policies: [Policy] {
        allPolicies.filter { $0.isActive }
    }

    var body: some View {
        NavigationStack {
            Group {
                if policies.isEmpty {
                    emptyState
                } else {
                    list
                }
            }
            .navigationTitle("Policies")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Label("Add Policy", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                PolicyFormView(mode: .add)
            }
        }
    }

    // MARK: - List

    private var list: some View {
        List {
            ForEach(policies) { policy in
                NavigationLink {
                    PolicyDetailView(policy: policy)
                } label: {
                    PolicyRowView(policy: policy)
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            Text("No Policies Yet")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Add your household bills and policies\nto keep track of renewals and costs.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button {
                showingAddSheet = true
            } label: {
                Label("Add Your First Policy", systemImage: "plus")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }
}

#Preview {
    let container = try! ModelContainer(
        for: Policy.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    PoliciesListView()
        .modelContainer(container)
}
