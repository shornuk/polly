//
//  PolicyRenewalView.swift
//  Polly
//

import SwiftUI
import SwiftData

struct PolicyRenewalView: View {
    let policy: Policy

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var notificationManager: NotificationManager

    // MARK: - State

    @State private var provider: String
    @State private var accountNumber: String
    @State private var cost: String
    @State private var frequency: Frequency
    @State private var paymentsPerYear: String
    @State private var useCustomPayments: Bool
    @State private var startDate: Date
    @State private var renewalDate: Date

    // MARK: - Init

    init(policy: Policy) {
        self.policy = policy

        let current = policy.currentCostRecord
        let oldRenewal = policy.renewalDate ?? Date()
        let nextRenewal = Calendar.current.date(byAdding: .year, value: 1, to: oldRenewal) ?? oldRenewal

        _provider = State(initialValue: policy.provider)
        _accountNumber = State(initialValue: policy.accountNumber ?? "")
        _cost = State(initialValue: current.map { "\($0.cost)" } ?? "")
        _frequency = State(initialValue: current?.frequency ?? .monthly)
        _paymentsPerYear = State(initialValue: current?.paymentsPerYear.map { "\($0)" } ?? "")
        _useCustomPayments = State(initialValue: current?.paymentsPerYear != nil)
        _startDate = State(initialValue: oldRenewal)
        _renewalDate = State(initialValue: nextRenewal)
    }

    // MARK: - Validation

    private var isCouncilTax: Bool {
        policy.category == .councilTax
    }

    private var parsedCost: Decimal? {
        Decimal(string: cost)
    }

    private var canSave: Bool {
        !provider.trimmingCharacters(in: .whitespaces).isEmpty && parsedCost != nil
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                providerSection
                costSection
                datesSection
            }
            .navigationTitle("Renew \(policy.displayName)")
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!canSave)
                }
            }
        }
    }

    // MARK: - Provider Section

    private var providerSection: some View {
        Section("Provider") {
            TextField("Provider", text: $provider)
            TextField("Account Number (optional)", text: $accountNumber)
                #if !os(macOS)
                .keyboardType(.default)
                #endif
        }
    }

    // MARK: - Cost Section

    private var costSection: some View {
        Section("New Cost") {
            HStack {
                Text("£")
                    .foregroundStyle(.secondary)
                TextField("Amount", text: $cost)
                    #if !os(macOS)
                    .keyboardType(.decimalPad)
                    #endif
            }
            Picker("Frequency", selection: $frequency) {
                ForEach(Frequency.allCases, id: \.self) { f in
                    Text(f.rawValue).tag(f)
                }
            }
            if isCouncilTax || useCustomPayments {
                HStack {
                    Text("Payments per year")
                    Spacer()
                    TextField("10", text: $paymentsPerYear)
                        #if !os(macOS)
                        .keyboardType(.numberPad)
                        #endif
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
                }
            }
            if !isCouncilTax {
                Toggle("Custom payments per year", isOn: $useCustomPayments)
                    .onChange(of: useCustomPayments) { _, on in
                        if !on { paymentsPerYear = "" }
                    }
            }
        }
    }

    // MARK: - Dates Section

    private var datesSection: some View {
        Section("New Dates") {
            DatePicker("Policy start date", selection: $startDate, displayedComponents: .date)
            DatePicker("Next renewal date", selection: $renewalDate, displayedComponents: .date)
        }
    }

    // MARK: - Save

    private func save() {
        guard let costValue = parsedCost else { return }

        let resolvedPayments: Int? = {
            if isCouncilTax || useCustomPayments {
                return Int(paymentsPerYear)
            }
            return nil
        }()

        let newPolicy = Policy(
            nickname: policy.nickname,
            category: policy.category,
            provider: provider.trimmingCharacters(in: .whitespaces),
            energyType: policy.energyType,
            accountNumber: accountNumber.trimmingCharacters(in: .whitespaces).isEmpty
                ? nil : accountNumber.trimmingCharacters(in: .whitespaces),
            startDate: startDate,
            renewalDate: renewalDate,
            autoRenews: policy.autoRenews,
            reminderEnabled: policy.reminderEnabled,
            reminderDaysBefore: policy.reminderDaysBefore,
            notes: policy.notes
        )

        let record = PolicyCostRecord(
            cost: costValue,
            frequency: frequency,
            paymentsPerYear: resolvedPayments,
            effectiveFrom: startDate,
            note: "Renewal"
        )
        newPolicy.costRecords.append(record)
        modelContext.insert(newPolicy)

        if newPolicy.reminderEnabled {
            notificationManager.scheduleReminder(for: newPolicy)
        }

        dismiss()
    }
}
