//
//  Vehicle.swift
//  Polly
//

import Foundation
import SwiftData

@Model
final class Vehicle {
    var id: UUID
    var make: String
    var model: String
    var year: Int?
    var registrationNumber: String?
    var estimatedValue: Decimal?
    var annualMileage: Int?
    var overnightParking: OvernightParking
    var hasModifications: Bool
    var modificationsDetail: String?

    init(
        make: String,
        model: String,
        year: Int? = nil,
        registrationNumber: String? = nil,
        estimatedValue: Decimal? = nil,
        annualMileage: Int? = nil,
        overnightParking: OvernightParking = .driveway,
        hasModifications: Bool = false,
        modificationsDetail: String? = nil
    ) {
        self.id = UUID()
        self.make = make
        self.model = model
        self.year = year
        self.registrationNumber = registrationNumber
        self.estimatedValue = estimatedValue
        self.annualMileage = annualMileage
        self.overnightParking = overnightParking
        self.hasModifications = hasModifications
        self.modificationsDetail = modificationsDetail
    }
}
