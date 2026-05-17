//
//  ConnectionTypeSheet.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 17/5/26.
//

import SwiftUI

struct ConnectionTypeSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var viewModel: SearchJourneyViewModel

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider()
            optionsList
            Spacer()
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Header

    private var header: some View {
        ZStack {
            Text("Type of Connection")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .center)
            HStack {
                Spacer()
                Button("Done") { dismiss() }
                    .foregroundColor(.primary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
    }

    // MARK: - Options

    private var optionsList: some View {
        VStack(spacing: 0) {
            ForEach(ConnectionType.allCases, id: \.self) { type in
                optionRow(type)
                if type != ConnectionType.allCases.last {
                    Divider().padding(.leading)
                }
            }
        }
        .background(Color(.systemBackground))
    }

    private func optionRow(_ type: ConnectionType) -> some View {
        Button {
            viewModel.uiState.connectionType = type
        } label: {
            HStack {
                Text(type.rawValue)
                    .font(.body)
                    .foregroundColor(.primary)
                Spacer()
                if viewModel.uiState.connectionType == type {
                    Image(systemName: "checkmark")
                        .foregroundColor(.green)
                        .font(.body.weight(.semibold))
                }
            }
            .padding()
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ConnectionTypeSheet()
        .environmentObject(SearchJourneyViewModel())
}
