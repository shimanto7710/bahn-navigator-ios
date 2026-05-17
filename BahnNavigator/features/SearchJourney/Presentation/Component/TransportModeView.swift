//
//  TransportModeView.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 16/5/26.
//

import SwiftUI

struct TransportModeView: View {
    @ObservedObject var viewModel: SearchJourneyViewModel
    let onDone: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                modeFilterSection
                transportTypeSection
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Mode of transport")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Done") { onDone() }
            }
        }
    }

    // MARK: - Mode filter (radio selection)

    private var modeFilterSection: some View {
        VStack(spacing: 0) {
            ForEach(TransportModeFilter.allCases, id: \.self) { mode in
                modeFilterRow(mode)
                if mode != TransportModeFilter.allCases.last {
                    Divider().padding(.leading)
                }
            }
        }
        .background(Color(.systemBackground))
    }

    private func modeFilterRow(_ mode: TransportModeFilter) -> some View {
        Button {
            viewModel.applyModeFilter(mode)
        } label: {
            HStack {
                Text(mode.rawValue)
                    .font(.body)
                    .foregroundColor(.primary)
                Spacer()
                if viewModel.uiState.transportOptions.modeFilter == mode {
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

    // MARK: - Individual transport types

    private var transportTypeSection: some View {
        VStack(spacing: 0) {
            transportRow(title: "High Speed Trains",
                         icon: .symbol("train.side.front.car"),
                         color: Color(white: 0.1),
                         isOn: $viewModel.uiState.transportOptions.highSpeedTrains)
            Divider().padding(.leading, 64)

            transportRow(title: "Intercity- and Eurocity trains",
                         icon: .symbol("train.side.front.car"),
                         color: Color(white: 0.3),
                         isOn: $viewModel.uiState.transportOptions.intercityTrains)
            Divider().padding(.leading, 64)

            transportRow(title: "Interregio- and Fast trains",
                         icon: .symbol("train.side.middle.car"),
                         color: Color(white: 0.45),
                         isOn: $viewModel.uiState.transportOptions.interregioTrains)
            Divider().padding(.leading, 64)

            transportRow(title: "Regional and other trains",
                         icon: .symbol("train.side.middle.car"),
                         color: Color(white: 0.55),
                         isOn: $viewModel.uiState.transportOptions.regionalTrains)
            Divider().padding(.leading, 64)

            transportRow(title: "S-Bahn",
                         icon: .letter("S"),
                         color: Color(red: 0.18, green: 0.54, blue: 0.18),
                         isOn: $viewModel.uiState.transportOptions.sBahn)
            Divider().padding(.leading, 64)

            transportRow(title: "Busses",
                         icon: .symbol("bus.fill"),
                         color: Color(red: 0.48, green: 0.18, blue: 0.54),
                         isOn: $viewModel.uiState.transportOptions.bus)
            Divider().padding(.leading, 64)

            transportRow(title: "Boats",
                         icon: .symbol("ferry.fill"),
                         color: Color(red: 0.18, green: 0.42, blue: 0.54),
                         isOn: $viewModel.uiState.transportOptions.boat)
            Divider().padding(.leading, 64)

            transportRow(title: "Underground",
                         icon: .letter("U"),
                         color: Color(red: 0.1, green: 0.23, blue: 0.54),
                         isOn: $viewModel.uiState.transportOptions.underground)
            Divider().padding(.leading, 64)

            transportRow(title: "Tram",
                         icon: .symbol("tram.fill"),
                         color: Color(red: 0.54, green: 0.18, blue: 0.18),
                         isOn: $viewModel.uiState.transportOptions.tram)
            Divider().padding(.leading, 64)

            transportRow(title: "Services requiring tel. registration",
                         icon: .symbol("car.fill"),
                         color: Color(red: 0.78, green: 0.63, blue: 0.1),
                         isOn: $viewModel.uiState.transportOptions.taxiService)
        }
        .background(Color(.systemBackground))
        .padding(.top, 8)
    }

    private func transportRow(
        title: String,
        icon: TransportIcon,
        color: Color,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(spacing: 12) {
            iconView(icon: icon, color: color)
            Toggle(isOn: isOn) {
                Text(title)
                    .font(.body)
            }
            .tint(.green)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    private func iconView(icon: TransportIcon, color: Color) -> some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 36, height: 36)
            switch icon {
            case .symbol(let name):
                Image(systemName: name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
            case .letter(let letter):
                Text(letter)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }
        }
    }

    // MARK: - Icon type

    enum TransportIcon {
        case symbol(String)
        case letter(String)
    }
}

#Preview {
    NavigationStack {
        TransportModeView(
            viewModel: SearchJourneyViewModel(),
            onDone: {}
        )
    }
}
