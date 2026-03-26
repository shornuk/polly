//
//  PolicyRowView.swift
//  Polly
//

import SwiftUI

struct PolicyRowView: View {
    let policy: Policy

    var body: some View {
        HStack(spacing: 12) {
            PolicyIconView(policy: policy)

            // Policy info
            VStack(alignment: .leading, spacing: 3) {
                Text(policy.displayName)
                    .font(.headline)
                VStack(alignment: .leading, spacing: 1) {
                    Text(policy.category.rawValue)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if policy.nickname != nil {
                        Text(policy.provider)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                if policy.isUpcoming, let days = policy.daysUntilStart {
                    startsBadge(days: days)
                } else if policy.isExpired, let days = policy.daysUntilRenewal {
                    expiredBadge(daysAgo: abs(days))
                } else if let days = policy.daysUntilRenewal {
                    renewalBadge(days: days)
                }
            }

            Spacer()

            // Cost
            if let costRecord = policy.currentCostRecord {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(costRecord.cost, format: .currency(code: "GBP"))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text(costRecord.frequency.rawValue)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Badges

    @ViewBuilder
    private func renewalBadge(days: Int) -> some View {
        if days == 0 {
            Text("Renews today")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        } else if days == 1 {
            Text("Renews tomorrow")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        } else if days > 1 {
            Text("Renews in \(days) days")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func startsBadge(days: Int) -> some View {
        if days == 0 {
            Text("Starts today")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        } else if days == 1 {
            Text("Starts tomorrow")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        } else {
            Text("Starts in \(days) days")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    @ViewBuilder
    private func expiredBadge(daysAgo: Int) -> some View {
        if daysAgo == 0 {
            Text("Expired today")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        } else if daysAgo == 1 {
            Text("Expired yesterday")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        } else {
            Text("Expired \(daysAgo) days ago")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
