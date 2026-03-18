//
//  Driver.swift
//  Polly
//

import Foundation
import SwiftData

@Model
final class Driver {
    var id: UUID
    var name: String
    var dateOfBirth: Date?
    var licenceNumber: String?
    var licenceType: LicenceType
    var licenceHeldSince: Date?
    var noClaimsYears: Int
    var hasConvictions: Bool
    var convictionDetails: String?
    var relationship: DriverRelationship
    var policy: Policy?

    init(
        name: String,
        dateOfBirth: Date? = nil,
        licenceNumber: String? = nil,
        licenceType: LicenceType = .full,
        licenceHeldSince: Date? = nil,
        noClaimsYears: Int = 0,
        hasConvictions: Bool = false,
        convictionDetails: String? = nil,
        relationship: DriverRelationship = .policyHolder
    ) {
        self.id = UUID()
        self.name = name
        self.dateOfBirth = dateOfBirth
        self.licenceNumber = licenceNumber
        self.licenceType = licenceType
        self.licenceHeldSince = licenceHeldSince
        self.noClaimsYears = noClaimsYears
        self.hasConvictions = hasConvictions
        self.convictionDetails = convictionDetails
        self.relationship = relationship
    }
}
