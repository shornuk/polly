//
//  PoliciesListView.swift
//  Polly
//

import SwiftUI
import SwiftData

private enum PolicyFilter: String, CaseIterable {
    case active   = "Active"
    case upcoming = "Upcoming"
    case archived = "Archived"
}

struct PoliciesListView: View {
    @State private var filter: PolicyFilter = .active
    @State private var showingAddSheet = false
    @Environment(\.modelContext) private var modelContext
    @Query private var allPolicies: [Policy]

    private var policies: [Policy] {
        let filtered: [Policy]
        switch filter {
        case .active:
            filtered = allPolicies.filter { $0.isActive && !$0.isUpcoming }
        case .upcoming:
            filtered = allPolicies.filter { $0.isUpcoming }
        case .archived:
            filtered = allPolicies.filter { !$0.isActive }
        }
        return filtered.sorted { $0.displayName.localizedCompare($1.displayName) == .orderedAscending }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("Filter", selection: $filter) {
                    ForEach(PolicyFilter.allCases, id: \.self) { tab in
                        Text(tab.rawValue).tag(tab)
                    }
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)

                if policies.isEmpty {
                    emptyState
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    list
                }
            }
            .navigationTitle("Policies")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.large)
            #endif
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if filter == .active {
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
                        .opacity(filter == .archived ? 0.65 : 1.0)
                }
                .swipeActions(edge: .leading) {
                    if filter == .archived {
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
            Image(systemName: emptyIcon)
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            Text(emptyTitle)
                .font(.title2)
                .fontWeight(.semibold)
            Text(emptyMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            if filter == .active {
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

    private var emptyIcon: String {
        switch filter {
        case .active:   return "list.bullet.rectangle"
        case .upcoming: return "calendar.badge.clock"
        case .archived: return "archivebox"
        }
    }

    private var emptyTitle: String {
        switch filter {
        case .active:   return "No Active Policies"
        case .upcoming: return "No Upcoming Policies"
        case .archived: return "No Archived Policies"
        }
    }

    private var emptyMessage: String {
        switch filter {
        case .active:
            return "Add your household bills and policies\nto keep track of renewals and costs."
        case .upcoming:
            return "Policies you've renewed in advance will appear here\nuntil their start date arrives."
        case .archived:
            return "Policies you archive will appear here.\nYou can restore them at any time."
        }
    }

    // MARK: - Actions

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
