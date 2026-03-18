//
//  PolicyCostRecord.swift
//  Polly
//

import Foundation
import SwiftData

@Model
final class PolicyCostRecord {
    var id: UUID
    var cost: Decimal
    var frequency: Frequency
    var paymentsPerYear: Int?
    var annualCost: Decimal?
    var effectiveFrom: Date
    var note: String?
    var policy: Policy?

    init(
        cost: Decimal,
        frequency: Frequency,
        paymentsPerYear: Int? = nil,
        annualCost: Decimal? = nil,
        effectiveFrom: Date = Date(),
        note: String? = nil
    ) {
        self.id = UUID()
        self.cost = cost
        self.frequency = frequency
        self.paymentsPerYear = paymentsPerYear
        self.annualCost = annualCost
        self.effectiveFrom = effectiveFrom
        self.note = note
    }

    /// Calculated annual cost — uses explicit annualCost if set,
    /// then paymentsPerYear override, then derives from frequency
    var calculatedAnnualCost: Decimal {
        if let annualCost {
            return annualCost
        }
        let payments = paymentsPerYear ?? frequency.paymentsPerYear
        return cost * Decimal(payments)
    }

    /// Monthly equivalent for dashboard summaries
    var monthlyEquivalent: Decimal {
        calculatedAnnualCost / 12
    }
}
