//
//  NearbyView.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 11/5/26.
//

import SwiftUI
import SwiftData

struct NearbyView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = NearbyViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.uiState.isLoading {
                    LoadingView()
                } else if let error = viewModel.uiState.errorMessage {
                    ErrorView(message: error) {
                        Task { await viewModel.load() }
                    }
                } else if viewModel.uiState.stations.isEmpty {
                    ErrorView(message: "No stations found nearby") {
                        Task { await viewModel.load() }
                    }
                } else {
                    stationList
                }
            }
            .navigationTitle("Nearby Stations")
        }
        .task {
            viewModel.configure(modelContext: modelContext)
            await viewModel.load()
        }
    }

    // MARK: - Station list

    private var stationList: some View {
        List(viewModel.uiState.stations, id: \.displayID) { station in
            HStack(spacing: 12) {
                Image(systemName: stationIcon(for: station))
                    .font(.system(size: 18))
                    .foregroundColor(.appDark)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 2) {
                    Text(station.name)
                        .font(.body)
                    Text(stationTypeLabel(for: station))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 4)
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Helpers

    private func stationIcon(for station: SearchStationModelElement) -> String {
        switch station.type {
        case .station, .stop: return "tram.fill"
        case .location:       return "mappin.circle.fill"
        }
    }

    private func stationTypeLabel(for station: SearchStationModelElement) -> String {
        switch station.type {
        case .station: return "Station"
        case .stop:    return "Stop"
        case .location: return station.address ?? "Location"
        }
    }
}
