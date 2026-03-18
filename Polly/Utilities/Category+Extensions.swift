//
//  Category+Extensions.swift
//  Polly
//

import SwiftUI

extension Category {
    var color: Color {
        switch self {
        case .energy: return .yellow
        case .water: return .blue
        case .broadband: return .purple
        case .mobile: return .indigo
        case .councilTax: return .brown
        case .homeInsurance: return .green
        case .carInsurance: return .red
        case .lifeInsurance: return .pink
        case .tvLicence: return .cyan
        case .breakdownCover: return .orange
        case .mortgageRent: return .teal
        case .subscriptions: return .mint
        case .other: return .gray
        }
    }
}
