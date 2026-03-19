//
//  PoliciesListView.swift
//  Polly
//

import SwiftUI
import SwiftData

struct PoliciesListView: View {
    @State private var showingAddSheet = false
    @State private var showingArchived = false
    @Environment(\.modelContext) private var modelContext
    @Query private var allPolicies: [Policy]

    private var policies: [Policy] {
        allPolicies
            .filter { showingArchived ? !$0.isActive : $0.isActive }
            .sorted { $0.displayName.localizedCompare($1.displayName) == .orderedAscending }
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
            .navigationTitle(showingArchived ? "Archived" : "Policies")
            .toolbar {
                ToolbarItem(placement: {
                    #if os(macOS)
                    return .navigation
                    #else
                    return .topBarLeading
                    #endif
                }()) {
                    Button {
                        showingArchived.toggle()
                    } label: {
                        Label("Archived", systemImage: showingArchived ? "archivebox.fill" : "archivebox")
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    if !showingArchived {
                        Button {
                            showingAddSheet = true
                        } label: {
                            Label("Add Policy", systemImage: "plus")
                        }
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
                        .opacity(showingArchived ? 0.65 : 1.0)
                }
                .swipeActions(edge: .leading) {
                    if showingArchived {
                        Button {
                            restorePolicy(policy)
                        } label: {
                            Label("Restore", systemImage: "arrow.uturn.backward")
                        }
                        .tint(.green)
                    }
                }
            }
        }
        #if os(macOS)
        .listStyle(.inset)
        #else
        .listStyle(.insetGrouped)
        #endif
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: showingArchived ? "archivebox" : "list.bullet.rectangle")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            Text(showingArchived ? "No Archived Policies" : "No Policies Yet")
                .font(.title2)
                .fontWeight(.semibold)
            Text(showingArchived
                 ? "Policies you archive will appear here. You can restore them at any time."
                 : "Add your household bills and policies\nto keep track of renewals and costs.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            if !showingArchived {
                Button {
                    showingAddSheet = true
                } label: {
                    Label("Add Your First Policy", systemImage: "plus")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
    }

    // MARK: - Restore

    private func restorePolicy(_ policy: Policy) {
        policy.isActive = true
        policy.endedAt = nil
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
