//
//  NearbyViewModel.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 11/5/26.
//

import Foundation
import SwiftData

@MainActor
final class NearbyViewModel: ObservableObject {
    @Published private(set) var uiState = NearbyUiState()

    private let locationManager: LocationManaging
    private var locationRepository: LocationRepositoryProtocol?

    init(locationManager: LocationManaging = LocationManager()) {
        self.locationManager = locationManager
    }

    func configure(modelContext: ModelContext) {
        guard locationRepository == nil else { return }
        let localDataSource = LocationLocalDataSource(modelContext: modelContext)
        locationRepository = LocationRepository(localDataSource: localDataSource)
    }

    /// Driven by `.task` in the view — auto-cancels on disappear.
    func load() async {
        uiState.isLoading = true
        uiState.errorMessage = nil

        do {
            let coordinate = try await locationManager.requestCurrentLocation()
            let stations = try await locationRepository?.getCurrentLocation(
                latitude: String(coordinate.latitude),
                longitude: String(coordinate.longitude)
            ) ?? []
            uiState.stations = stations
        } catch is CancellationError {
            return
        } catch {
            uiState.errorMessage = "Could not load nearby stations. Make sure location access is enabled."
        }

        uiState.isLoading = false
    }
}

struct NearbyUiState {
    var stations: [SearchStationModelElement] = []
    var isLoading = false
    var errorMessage: String?
}
