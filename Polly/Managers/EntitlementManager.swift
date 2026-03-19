//
//  EntitlementManager.swift
//  Polly
//
//  Stub entitlement manager — isPremium is hardcoded to true until
//  StoreKit 2 is implemented. Replace the body of checkEntitlements()
//  with real product verification when the paywall is built.
//

import Foundation
import Combine

final class EntitlementManager: ObservableObject {
    static let shared = EntitlementManager()
    private init() {}

    /// Whether the user has unlocked premium features.
    /// Currently hardcoded to true — swap for StoreKit verification later.
    @Published var isPremium: Bool = true

    // MARK: - StoreKit hook (future)

    /// Call this from PollyApp when StoreKit is implemented.
    func checkEntitlements() async {
        // TODO: verify purchase receipt / Transaction.currentEntitlements
        // For now, premium is always granted.
    }
}
