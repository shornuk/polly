//
//  PolicyIconView.swift
//  Polly
//

import SwiftUI

struct PolicyIconView: View {
    let policy: Policy
    var size: CGFloat = 44
    var cornerRadius: CGFloat = 10

    private var logoName: String {
        "provider-" + policy.provider.lowercased().replacingOccurrences(of: " ", with: "-")
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius)
                .fill(policy.category.color.gradient)
                .frame(width: size, height: size)
            if UIImage(named: logoName) != nil {
                Image(logoName)
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .clipShape(RoundedRectangle(cornerRadius: cornerRadius))
            } else {
                Image(systemName: policy.category.icon)
                    .font(.system(size: size * 0.45))
                    .foregroundStyle(.white)
            }
        }
    }
}
