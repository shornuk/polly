//
//  DashboardView.swift
//  Polly
//

import SwiftUI
import SwiftData

private extension Color {
    static var systemGroupedBackground: Color {
        #if os(macOS)
        Color(NSColor.windowBackgroundColor)
        #else
        Color(.systemGroupedBackground)
        #endif
    }
    static var secondarySystemGroupedBackground: Color {
        #if os(macOS)
        Color(NSColor.controlBackgroundColor)
        #else
        Color(.secondarySystemGroupedBackground)
        #endif
    }
}

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allPolicies: [Policy]

    private var activePolicies: [Policy] {
        allPolicies.filter { $0.isActive && !$0.isUpcoming && !$0.isExpired }
    }

    private var overduePolicies: [Policy] {
        activePolicies.filter { $0.isOverdue }
    }

    private var upcomingPolicies: [Policy] {
        activePolicies
            .filter { $0.isDueForRenewal(within: 90) }
            .sorted { lhs, rhs in
                guard let l = lhs.daysUntilRenewal,
                      let r = rhs.daysUntilRenewal else { return false }
                return l < r
            }
    }

    private var missingRenewalDate: [Policy] {
        activePolicies.filter { $0.renewalDate == nil }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if activePolicies.isEmpty {
                        emptyState
                    } else {
                        if !overduePolicies.isEmpty {
                            overdueSection
                        }
                        if !upcomingPolicies.isEmpty {
                            upcomingSection
                        }
                        if overduePolicies.isEmpty && upcomingPolicies.isEmpty {
                            allClearView
                        }
                        if !missingRenewalDate.isEmpty {
                            missingDatesSection
                        }
                    }
                }
                .padding()
            }
            .navigationTitle("Home")
            .background(Color.systemGroupedBackground)
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "house.fill")
                .font(.system(size: 56))
                .foregroundStyle(.secondary)
            Text("Welcome to Polly")
                .font(.title2)
                .fontWeight(.semibold)
            Text("Add your household bills and policies\nto start tracking renewals.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.top, 60)
    }

    // MARK: - All Clear

    private var allClearView: some View {
        VStack(spacing: 12) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)
            Text("All Clear")
                .font(.title3)
                .fontWeight(.semibold)
            Text("No renewals due in the next 90 days.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(Color.secondarySystemGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Overdue Section

    private var overdueSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Overdue", systemImage: "exclamationmark.circle.fill")
                .font(.headline)
                .foregroundStyle(.red)

            ForEach(overduePolicies) { policy in
                NavigationLink {
                    PolicyDetailView(policy: policy)
                } label: {
                    DashboardPolicyCard(policy: policy)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Upcoming Section

    private var upcomingSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Renewals")
                .font(.headline)
                .foregroundStyle(.primary)

            ForEach(upcomingPolicies) { policy in
                NavigationLink {
                    PolicyDetailView(policy: policy)
                } label: {
                    DashboardPolicyCard(policy: policy)
                }
                .buttonStyle(.plain)
            }
        }
    }

    // MARK: - Missing Dates Section

    private var missingDatesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Missing Renewal Date", systemImage: "calendar.badge.exclamationmark")
                .font(.headline)
                .foregroundStyle(.orange)

            ForEach(missingRenewalDate) { policy in
                NavigationLink {
                    PolicyDetailView(policy: policy)
                } label: {
                    HStack(spacing: 12) {
                        PolicyIconView(policy: policy, size: 40)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(policy.displayName)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.primary)
                            Text("Tap to add renewal date")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(12)
                    .background(Color.secondarySystemGroupedBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Dashboard Policy Card

struct DashboardPolicyCard: View {
    let policy: Policy

    var body: some View {
        HStack(spacing: 12) {
            PolicyIconView(policy: policy)

            VStack(alignment: .leading, spacing: 3) {
                Text(policy.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                Text(policy.category.rawValue)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if policy.nickname != nil {
                    Text(policy.provider)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                if let days = policy.daysUntilRenewal {
                    if days < 0 {
                        Text("Overdue")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.red)
                            .clipShape(Capsule())
                    } else if days == 0 {
                        Text("Today")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.orange)
                            .clipShape(Capsule())
                    } else {
                        Text("\(days) days")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(days <= 30 ? .orange : .secondary)
                    }
                }
                if let costRecord = policy.currentCostRecord {
                    Text(costRecord.cost, format: .currency(code: "GBP"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color.secondarySystemGroupedBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    DashboardView()
        .modelContainer(for: Policy.self, inMemory: true)
}
