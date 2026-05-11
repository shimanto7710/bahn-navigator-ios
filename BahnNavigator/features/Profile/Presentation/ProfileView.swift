//
//  ProfileView.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 11/5/26.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        NavigationStack {
            List {
                // MARK: Account

                Section("Account") {
                    profileRow(icon: "person.circle", title: "Personal Details")
                    profileRow(icon: "creditcard", title: "Payment Methods")
                    profileRow(icon: "ticket", title: "BahnCard")
                }

                // MARK: Preferences

                Section("Preferences") {
                    profileRow(icon: "bell", title: "Notifications")
                    profileRow(icon: "globe", title: "Language")
                    profileRow(icon: "lock.shield", title: "Privacy")
                }

                // MARK: Support

                Section("Support") {
                    profileRow(icon: "questionmark.circle", title: "Help & FAQ")
                    profileRow(icon: "envelope", title: "Contact Support")
                    profileRow(icon: "info.circle", title: "About")
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Profile")
        }
    }

    private func profileRow(icon: String, title: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.appDark)
                .frame(width: 24)

            Text(title)

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundColor(Color(.tertiaryLabel))
        }
        .padding(.vertical, 2)
    }
}
