//
//  Enums.swift
//  Polly
//

import Foundation

// MARK: - Policy Category

enum Category: String, Codable, CaseIterable {
    case energy = "Energy"
    case water = "Water"
    case broadband = "Broadband"
    case mobile = "Mobile"
    case councilTax = "Council Tax"
    case homeInsurance = "Home Insurance"
    case carInsurance = "Car Insurance"
    case lifeInsurance = "Life Insurance"
    case tvLicence = "TV Licence"
    case breakdownCover = "Breakdown Cover"
    case mortgageRent = "Mortgage / Rent"
    case subscriptions = "Subscriptions"
    case other = "Other"

    var icon: String {
        switch self {
        case .energy: return "bolt.fill"
        case .water: return "drop.fill"
        case .broadband: return "wifi"
        case .mobile: return "iphone"
        case .councilTax: return "building.columns.fill"
        case .homeInsurance: return "house.fill"
        case .carInsurance: return "car.fill"
        case .lifeInsurance: return "heart.fill"
        case .tvLicence: return "tv.fill"
        case .breakdownCover: return "wrench.and.screwdriver.fill"
        case .mortgageRent: return "key.fill"
        case .subscriptions: return "rectangle.stack.fill"
        case .other: return "square.grid.2x2.fill"
        }
    }
}

// MARK: - Energy Type

enum EnergyType: String, Codable, CaseIterable {
    case gas = "Gas"
    case electric = "Electric"
    case dualFuel = "Dual Fuel"
}

// MARK: - Payment Frequency

enum Frequency: String, Codable, CaseIterable {
    case weekly = "Weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case sixMonthly = "Six Monthly"
    case annual = "Annual"
    case oneOff = "One Off"

    var paymentsPerYear: Int {
        switch self {
        case .weekly: return 52
        case .monthly: return 12
        case .quarterly: return 4
        case .sixMonthly: return 2
        case .annual: return 1
        case .oneOff: return 1
        }
    }
}

// MARK: - Payment Method

enum PaymentMethod: String, Codable, CaseIterable {
    case directDebit = "Direct Debit"
    case card = "Card"
    case cash = "Cash"
    case bankTransfer = "Bank Transfer"
    case other = "Other"
}

// MARK: - File Type

enum FileType: String, Codable, CaseIterable {
    case pdf = "PDF"
    case image = "Image"
}

// MARK: - Licence Type

enum LicenceType: String, Codable, CaseIterable {
    case full = "Full"
    case provisional = "Provisional"
}

// MARK: - Driver Relationship

enum DriverRelationship: String, Codable, CaseIterable {
    case policyHolder = "Policy Holder"
    case spouse = "Spouse"
    case partner = "Partner"
    case other = "Other"
}

// MARK: - Property Type

enum PropertyType: String, Codable, CaseIterable {
    case detached = "Detached"
    case semiDetached = "Semi-Detached"
    case terraced = "Terraced"
    case flat = "Flat"
    case bungalow = "Bungalow"
}

// MARK: - Construction Type

enum ConstructionType: String, Codable, CaseIterable {
    case standard = "Standard"
    case nonStandard = "Non-Standard"
}

// MARK: - Roof Type

enum RoofType: String, Codable, CaseIterable {
    case standard = "Standard"
    case flat = "Flat"
    case thatched = "Thatched"
}

// MARK: - Overnight Parking

enum OvernightParking: String, Codable, CaseIterable {
    case garage = "Garage"
    case driveway = "Driveway"
    case street = "Street"
    case other = "Other"
}
