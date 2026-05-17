//
//  OptionSheet.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 16/5/26.
//

import SwiftUI

struct OptionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var viewModel: SearchJourneyViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                optionsList
                resetSection
                Spacer()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Options")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    // MARK: - Options list

    private var optionsList: some View {
        VStack(spacing: 0) {
            NavigationLink {
                TransportModeView(viewModel: viewModel, onDone: { dismiss() })
            } label: {
                navigationRow(
                    title: "Mode of transport",
                    value: viewModel.uiState.transportOptions.modeFilter.rawValue
                )
            }
            .buttonStyle(.plain)

            Divider().padding(.leading)
            toggleRow(title: "D-Ticket services only",     isOn: $viewModel.uiState.transportOptions.dTicketOnly)
            Divider().padding(.leading)
            toggleRow(title: "Bicycle transport possible", isOn: $viewModel.uiState.transportOptions.bicycle)
            Divider().padding(.leading)
            toggleRow(title: "Direct services only",       isOn: $viewModel.uiState.transportOptions.directService)
            Divider().padding(.leading)
            navigationRow(title: "Transfer time", value: "Standard")
            Divider().padding(.leading)
            navigationRow(title: "Stopovers",     value: "None")
        }
        .background(Color(.systemBackground))
    }

    // MARK: - Reset

    private var resetSection: some View {
        Button {
            viewModel.resetTransportOptions()
        } label: {
            Text("Reset")
                .font(.body)
                .foregroundColor(.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color(.systemGray4), lineWidth: 1))
        }
        .buttonStyle(.plain)
        .padding()
    }

    // MARK: - Row builders

    private func toggleRow(title: String, isOn: Binding<Bool>) -> some View {
        Toggle(isOn: isOn) {
            Text(title)
                .font(.body)
        }
        .tint(Color.appRed)
        .padding()
    }

    private func navigationRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.body)
                .foregroundColor(.primary)
            Spacer()
            Text(value)
                .font(.body)
                .foregroundColor(.secondary)
                .lineLimit(1)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.semibold))
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    OptionSheet(viewModel: SearchJourneyViewModel())
}
