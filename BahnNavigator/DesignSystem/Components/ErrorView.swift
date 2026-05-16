//
//  ErrorView.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 11/5/26.
//

import SwiftUI

struct ErrorView: View {
    let message: String
    let retry: (() -> Void)?

    init(message: String, retry: (() -> Void)? = nil) {
        self.message = message
        self.retry = retry
    }

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "wifi.slash")
                .font(.system(size: 40))
                .foregroundColor(.secondary)

            Text(message)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)

            if let retry {
                Button("Try Again", action: retry)
                    .buttonStyle(.bordered)
                    .tint(.appDark)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

