//
//  PolicyFormView.swift
//  Polly
//

import SwiftUI
import SwiftData

struct PolicyFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var notificationManager: NotificationManager

    // MARK: - Mode
    enum Mode {
        case add
        case edit(Policy)
    }

    let mode: Mode

    // MARK: - Form Fields
    @State private var nickname: String = ""
    @State private var category: Category = .energy
    @State private var energyType: EnergyType = .dualFuel
    @State private var provider: String = ""
    @State private var accountNumber: String = ""
    @State private var cost: String = ""
    @State private var frequency: Frequency = .monthly
    @State private var paymentsPerYear: String = ""
    @State private var useCustomPayments: Bool = false
    @State private var startDate: Date = Date()
    @State private var renewalDate: Date = Date()
    @State private var hasStartDate: Bool = false
    @State private var hasRenewalDate: Bool = false
    @State private var autoRenews: Bool = false
    @State private var reminderEnabled: Bool = true
    @State private var reminderDaysBefore: Int = 30
    @State private var notes: String = ""

    // MARK: - Validation
    private var isValid: Bool {
        !provider.trimmingCharacters(in: .whitespaces).isEmpty &&
        !cost.isEmpty &&
        Decimal(string: cost) != nil
    }

    // MARK: - Title
    private var title: String {
        switch mode {
        case .add: return "New Policy"
        case .edit: return "Edit Policy"
        }
    }

    var body: some View {
        NavigationStack {
            Form {
                aboutSection
                costSection
                datesSection
                remindersSection
                notesSection
            }
            .navigationTitle(title)
            #if !os(macOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        save()
                    }
                    .disabled(!isValid)
                }
            }
            .onAppear {
                loadExistingData()
            }
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Section("About") {
            Picker("Category", selection: $category) {
                ForEach(Category.allCases, id: \.self) { cat in
                    Label(cat.rawValue, systemImage: cat.icon)
                        .tag(cat)
                }
            }
            if category == .energy {
                Picker("Energy Type", selection: $energyType) {
                    ForEach(EnergyType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
            }
            providerField
            TextField("Account / policy number", text: $accountNumber)
            TextField("Nickname (optional)", text: $nickname)
        }
    }

    // MARK: - Provider Field with Suggestions

    private var providerField: some View {
        VStack(alignment: .leading, spacing: 0) {
            TextField("Provider", text: $provider)
            let suggestions = providerSuggestions.filter {
                !provider.isEmpty &&
                $0.localizedCaseInsensitiveContains(provider) &&
                $0.lowercased() != provider.lowercased()
            }
            if !suggestions.isEmpty {
                Divider()
                ForEach(suggestions, id: \.self) { suggestion in
                    Button {
                        provider = suggestion
                    } label: {
                        Text(suggestion)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.vertical, 8)
                    }
                    if suggestion != suggestions.last {
                        Divider()
                    }
                }
            }
        }
    }

    // MARK: - Cost Section

    private var costSection: some View {
        Section("Cost") {
            HStack {
                Text("£")
                    .foregroundStyle(.secondary)
                TextField("Amount", text: $cost)
                    #if !os(macOS)
                    .keyboardType(.decimalPad)
                    #endif
            }
            Picker("Frequency", selection: $frequency) {
                ForEach(Frequency.allCases, id: \.self) { freq in
                    Text(freq.rawValue).tag(freq)
                }
            }
            if category == .councilTax || useCustomPayments {
                HStack {
                    Text("Payments per year")
                    Spacer()
                    TextField("e.g. 10", text: $paymentsPerYear)
                        #if !os(macOS)
                        .keyboardType(.numberPad)
                        #endif
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
                }
            }
            if category != .councilTax {
                Toggle("Custom payment schedule", isOn: $useCustomPayments)
            }
        }
    }

    // MARK: - Dates Section

    private var datesSection: some View {
        Section("Dates") {
            Toggle("Has start date", isOn: $hasStartDate)
            if hasStartDate {
                DatePicker("Start Date",
                    selection: $startDate,
                    displayedComponents: .date)
            }
            Toggle("Has renewal date", isOn: $hasRenewalDate)
            if hasRenewalDate {
                DatePicker("Renewal Date",
                    selection: $renewalDate,
                    displayedComponents: .date)
            }
            Toggle("Auto renews", isOn: $autoRenews)
        }
    }

    // MARK: - Reminders Section

    private var remindersSection: some View {
        Section("Reminders") {
            Toggle("Enable reminder", isOn: $reminderEnabled)
            if reminderEnabled {
                Picker("Notify me", selection: $reminderDaysBefore) {
                    Text("1 day before").tag(1)
                    Text("2 days before").tag(2)
                    Text("3 days before").tag(3)
                    Text("7 days before").tag(7)
                    Text("14 days before").tag(14)
                    Text("30 days before").tag(30)
                    Text("60 days before").tag(60)
                    Text("90 days before").tag(90)
                }
            }
        }
    }

    // MARK: - Notes Section

    private var notesSection: some View {
        Section("Notes") {
            TextField("Any additional notes...",
                text: $notes,
                axis: .vertical)
                .lineLimit(4...8)
        }
    }

    // MARK: - Provider Suggestions

    private var providerSuggestions: [String] {
        switch category {
        case .energy:
            return ["Octopus Energy", "British Gas", "EDF Energy", "E.ON Next",
                    "OVO Energy", "Scottish Power", "Shell Energy", "Utilita",
                    "So Energy", "Outfox the Market"]
        case .homeInsurance:
            return ["Aviva", "Direct Line", "Admiral", "Churchill", "Halifax",
                    "LV=", "NFU Mutual", "AXA", "Hastings Direct", "More Than"]
        case .carInsurance:
            return ["Admiral", "Aviva", "Churchill", "Direct Line",
                    "Hastings Direct", "LV=", "More Than", "NFU Mutual",
                    "Tesco Bank", "AXA"]
        case .broadband:
            return ["BT", "Sky", "Virgin Media", "TalkTalk", "Plusnet",
                    "EE", "Vodafone", "Hyperoptic", "Zen Internet", "NOW Broadband"]
        case .mobile:
            return ["EE", "O2", "Vodafone", "Three", "Sky Mobile",
                    "giffgaff", "SMARTY", "Tesco Mobile", "iD Mobile"]
        case .breakdownCover:
            return ["AA", "RAC", "Green Flag", "Admiral", "Start Rescue"]
        case .lifeInsurance:
            return ["Aviva", "Legal & General", "Royal London",
                    "VitalityLife", "AIG", "Zurich", "LV=", "Scottish Widows"]
        case .tvLicence:
            return ["TV Licensing"]
        default:
            return []
        }
    }

    // MARK: - Save

    private func save() {
        let costDecimal = Decimal(string: cost) ?? 0
        let customPayments = useCustomPayments || category == .councilTax
            ? Int(paymentsPerYear)
            : nil

        switch mode {
        case .add:
            let policy = Policy(
                nickname: nickname.isEmpty ? nil : nickname,
                category: category,
                provider: provider,
                energyType: category == .energy ? energyType : nil,
                accountNumber: accountNumber.isEmpty ? nil : accountNumber,
                startDate: hasStartDate ? startDate : nil,
                renewalDate: hasRenewalDate ? renewalDate : nil,
                autoRenews: autoRenews,
                reminderEnabled: reminderEnabled,
                reminderDaysBefore: reminderDaysBefore,
                notes: notes.isEmpty ? nil : notes
            )
            let costRecord = PolicyCostRecord(
                cost: costDecimal,
                frequency: frequency,
                paymentsPerYear: customPayments
            )
            policy.costRecords.append(costRecord)
            modelContext.insert(policy)
            if policy.reminderEnabled {
                notificationManager.scheduleReminder(for: policy)
            }

        case .edit(let policy):
            policy.nickname = nickname.isEmpty ? nil : nickname
            policy.category = category
            policy.energyType = category == .energy ? energyType : nil
            policy.provider = provider
            policy.accountNumber = accountNumber.isEmpty ? nil : accountNumber
            policy.startDate = hasStartDate ? startDate : nil
            policy.renewalDate = hasRenewalDate ? renewalDate : nil
            policy.autoRenews = autoRenews
            policy.reminderEnabled = reminderEnabled
            policy.reminderDaysBefore = reminderDaysBefore
            policy.notes = notes.isEmpty ? nil : notes
            policy.updatedAt = Date()

            let currentCost = policy.currentCostRecord
            if currentCost?.cost != costDecimal ||
               currentCost?.frequency != frequency {
                let costRecord = PolicyCostRecord(
                    cost: costDecimal,
                    frequency: frequency,
                    paymentsPerYear: customPayments
                )
                policy.costRecords.append(costRecord)
            }
            // Schedule or cancel reminder
            if policy.reminderEnabled {
                notificationManager.scheduleReminder(for: policy)
            } else {
                notificationManager.cancelReminder(for: policy)
            }
        }
        dismiss()
    }

    // MARK: - Load Existing Data

    private func loadExistingData() {
        guard case .edit(let policy) = mode else { return }
        nickname = policy.nickname ?? ""
        category = policy.category
        energyType = policy.energyType ?? .dualFuel
        provider = policy.provider
        accountNumber = policy.accountNumber ?? ""
        hasStartDate = policy.startDate != nil
        startDate = policy.startDate ?? Date()
        hasRenewalDate = policy.renewalDate != nil
        renewalDate = policy.renewalDate ?? Date()
        autoRenews = policy.autoRenews
        reminderEnabled = policy.reminderEnabled
        reminderDaysBefore = policy.reminderDaysBefore
        notes = policy.notes ?? ""
        if let costRecord = policy.currentCostRecord {
            cost = "\(costRecord.cost)"
            frequency = costRecord.frequency
            if let payments = costRecord.paymentsPerYear {
                paymentsPerYear = "\(payments)"
                useCustomPayments = true
            }
        }
    }
}

#Preview {
    PolicyFormView(mode: .add)
        .modelContainer(for: Policy.self, inMemory: true)
}
