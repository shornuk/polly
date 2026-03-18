//
//  Property.swift
//  Polly
//

import Foundation
import SwiftData

@Model
final class InsuredProperty {
    var id: UUID
    var address: String
    var propertyType: PropertyType
    var bedrooms: Int
    var yearBuilt: Int?
    var constructionType: ConstructionType
    var roofType: RoofType
    var hasAlarm: Bool
    var hasSmokeAlarms: Bool
    var previousClaims: [PropertyClaim]

    init(
        address: String,
        propertyType: PropertyType = .detached,
        bedrooms: Int = 3,
        yearBuilt: Int? = nil,
        constructionType: ConstructionType = .standard,
        roofType: RoofType = .standard,
        hasAlarm: Bool = false,
        hasSmokeAlarms: Bool = true,
        previousClaims: [PropertyClaim] = []
    ) {
        self.id = UUID()
        self.address = address
        self.propertyType = propertyType
        self.bedrooms = bedrooms
        self.yearBuilt = yearBuilt
        self.constructionType = constructionType
        self.roofType = roofType
        self.hasAlarm = hasAlarm
        self.hasSmokeAlarms = hasSmokeAlarms
        self.previousClaims = previousClaims
    }
}

// Embedded struct — no separate @Model needed as it's
// always owned by an InsuredProperty
struct PropertyClaim: Codable {
    var id: UUID
    var date: Date
    var type: String
    var amount: Decimal?
    var settled: Bool

    init(
        date: Date,
        type: String,
        amount: Decimal? = nil,
        settled: Bool = false
    ) {
        self.id = UUID()
        self.date = date
        self.type = type
        self.amount = amount
        self.settled = settled
    }
}
