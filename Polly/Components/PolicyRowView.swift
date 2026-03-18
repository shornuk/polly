//
//  PolicyRowView.swift
//  Polly
//

import SwiftUI

struct PolicyRowView: View {
    let policy: Policy

    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(policy.category.color.gradient)
                    .frame(width: 44, height: 44)
                Image(systemName: policy.category.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(.white)
            }

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
                if let days = policy.daysUntilRenewal {
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

    // MARK: - Renewal Badge

    @ViewBuilder
    private func renewalBadge(days: Int) -> some View {
        if days < 0 {
            Text("Overdue")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        } else if days == 0 {
            Text("Renews today")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        } else if days == 1 {
            Text("Renews tomorrow")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        } else if days <= 30 {
            Text("Renews in \(days) days")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        } else if days <= 90 {
            Text("Renews in \(days) days")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}
