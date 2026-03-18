//
//  PolicyDetailView.swift
//  Polly
//

import SwiftUI

struct PolicyDetailView: View {
    let policy: Policy
    @State private var showingEditSheet = false

    var body: some View {
        List {
            // MARK: - Header
            Section {
                HStack(spacing: 16) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(policy.category.color.gradient)
                            .frame(width: 60, height: 60)
                        Image(systemName: policy.category.icon)
                            .font(.system(size: 28))
                            .foregroundStyle(.white)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(policy.displayName)
                            .font(.title3)
                            .fontWeight(.semibold)
                        Text(policy.provider)
                            .foregroundStyle(.secondary)
                        if let energyType = policy.energyType {
                            Text(energyType.rawValue)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(.vertical, 4)
            }

            // MARK: - Current Cost
            if let costRecord = policy.currentCostRecord {
                Section("Current Cost") {
                    LabeledContent("Amount") {
                        Text(costRecord.cost, format: .currency(code: "GBP"))
                            .fontWeight(.semibold)
                    }
                    LabeledContent("Frequency") {
                        Text(costRecord.frequency.rawValue)
                    }
                    if let payments = costRecord.paymentsPerYear {
                        LabeledContent("Payments per year") {
                            Text("\(payments)")
                        }
                    }
                    LabeledContent("Annual equivalent") {
                        Text(costRecord.calculatedAnnualCost, format: .currency(code: "GBP"))
                            .foregroundStyle(.secondary)
                    }
                    LabeledContent("Monthly equivalent") {
                        Text(costRecord.monthlyEquivalent, format: .currency(code: "GBP"))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            // MARK: - Policy Details
            Section("Policy Details") {
                if let accountNumber = policy.accountNumber {
                    LabeledContent("Account Number", value: accountNumber)
                }
                if let startDate = policy.startDate {
                    LabeledContent("Start Date") {
                        Text(startDate, format: .dateTime.day().month().year())
                    }
                }
                if let renewalDate = policy.renewalDate {
                    LabeledContent("Renewal Date") {
                        VStack(alignment: .trailing, spacing: 2) {
                            Text(renewalDate, format: .dateTime.day().month().year())
                            if let days = policy.daysUntilRenewal {
                                renewalLabel(days: days)
                            }
                        }
                    }
                }
                LabeledContent("Auto Renews") {
                    Text(policy.autoRenews ? "Yes" : "No")
                }
            }

            // MARK: - Reminders
            Section("Reminders") {
                LabeledContent("Reminder") {
                    Text(policy.reminderEnabled ? "Enabled" : "Disabled")
                }
                if policy.reminderEnabled {
                    LabeledContent("Notify before renewal") {
                        Text("\(policy.reminderDaysBefore) days")
                    }
                }
            }

            // MARK: - Notes
            if let notes = policy.notes, !notes.isEmpty {
                Section("Notes") {
                    Text(notes)
                        .foregroundStyle(.secondary)
                }
            }

            // MARK: - Documents placeholder
            Section("Documents") {
                if policy.documents.isEmpty {
                    Text("No documents attached")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(policy.documents) { document in
                        Label(document.label, systemImage:
                            document.fileType == .pdf ? "doc.fill" : "photo.fill")
                    }
                }
            }
        }
        .navigationTitle(policy.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("Edit") {
                    showingEditSheet = true
                }
            }
        }
        .sheet(isPresented: $showingEditSheet) {
            PolicyFormView(mode: .edit(policy))
        }
    }

    // MARK: - Renewal Label

    @ViewBuilder
    private func renewalLabel(days: Int) -> some View {
        if days < 0 {
            Text("Overdue by \(abs(days)) days")
                .font(.caption)
                .foregroundStyle(.red)
        } else if days == 0 {
            Text("Due today")
                .font(.caption)
                .foregroundStyle(.orange)
        } else if days <= 30 {
            Text("In \(days) days")
                .font(.caption)
                .foregroundStyle(.orange)
        } else {
            Text("In \(days) days")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
