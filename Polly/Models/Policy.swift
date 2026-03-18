//
//  Policy.swift
//  Polly
//

import Foundation
import SwiftData

@Model
final class Policy {
    var id: UUID
    var nickname: String?
    var category: Category
    var energyType: EnergyType?
    var provider: String
    var accountNumber: String?
    var startDate: Date?
    var renewalDate: Date?
    var autoRenews: Bool
    var reminderEnabled: Bool
    var reminderDaysBefore: Int
    var notes: String?
    var isActive: Bool
    var endedAt: Date?
    var createdAt: Date
    var updatedAt: Date

    // MARK: - Relationships

    @Relationship(deleteRule: .cascade, inverse: \PolicyCostRecord.policy)
    var costRecords: [PolicyCostRecord] = []

    @Relationship(deleteRule: .cascade, inverse: \PolicyDocument.policy)
    var documents: [PolicyDocument] = []

    @Relationship(deleteRule: .cascade, inverse: \Driver.policy)
    var drivers: [Driver] = []

    @Relationship(deleteRule: .cascade)
    var vehicle: Vehicle?

    @Relationship(deleteRule: .cascade)
    var property: InsuredProperty?

    // MARK: - Init

    init(
        nickname: String? = nil,
        category: Category,
        provider: String,
        energyType: EnergyType? = nil,
        accountNumber: String? = nil,
        startDate: Date? = nil,
        renewalDate: Date? = nil,
        autoRenews: Bool = false,
        reminderEnabled: Bool = true,
        reminderDaysBefore: Int = 30,
        notes: String? = nil
    ) {
        self.id = UUID()
        self.nickname = nickname
        self.category = category
        self.energyType = energyType
        self.provider = provider
        self.accountNumber = accountNumber
        self.startDate = startDate
        self.renewalDate = renewalDate
        self.autoRenews = autoRenews
        self.reminderEnabled = reminderEnabled
        self.reminderDaysBefore = reminderDaysBefore
        self.notes = notes
        self.isActive = true
        self.endedAt = nil
        self.createdAt = Date()
        self.updatedAt = Date()
    }

    // MARK: - Computed Properties

    /// The most recent cost record by effectiveFrom date
    var currentCostRecord: PolicyCostRecord? {
        costRecords.sorted { $0.effectiveFrom > $1.effectiveFrom }.first
    }

    /// Current monthly equivalent cost for dashboard summaries
    var monthlyEquivalent: Decimal? {
        currentCostRecord?.monthlyEquivalent
    }

    /// Days until renewal — nil if no renewal date set
    var daysUntilRenewal: Int? {
        guard let renewalDate else { return nil }
        return Calendar.current.dateComponents(
            [.day],
            from: Calendar.current.startOfDay(for: Date()),
            to: Calendar.current.startOfDay(for: renewalDate)
        ).day
    }

    /// Whether the policy is due for renewal within a given number of days
    func isDueForRenewal(within days: Int) -> Bool {
        guard let daysUntilRenewal else { return false }
        return daysUntilRenewal >= 0 && daysUntilRenewal <= days
    }

    /// Whether the renewal date has passed
    var isOverdue: Bool {
        guard let daysUntilRenewal else { return false }
        return daysUntilRenewal < 0
    }
    
    var displayName: String {
        nickname ?? provider
    }
}
