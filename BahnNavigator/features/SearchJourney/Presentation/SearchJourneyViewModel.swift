//
//  SearchJourneyViewModel.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 8/5/26.
//

import Combine
import Foundation
import CoreLocation
import SwiftData

enum LocationPickerField {
    case origin
    case destination

    var title: String {
        switch self {
        case .origin:
            return "Select point of departure"
        case .destination:
            return "Select destination"
        }
    }
}

@MainActor
final class SearchJourneyViewModel: ObservableObject {
    /// Delay before a typed query is sent to the network, to avoid hammering the
    /// backend while the user is still typing.
    private static let searchDebounceNanoseconds: UInt64 = 300_000_000

    @Published private(set) var uiState = SearchJourneyUiState()
    @Published var shouldNavigateToResults = false
    @Published private(set) var journeySearchParams: JourneySearchParams?

    private let locationManager: LocationManaging
    private var locationRepository: LocationRepositoryProtocol?
    private var locationSearchTask: Task<Void, Never>?

    init(
        locationManager: LocationManaging = LocationManager()
    ) {
        self.locationManager = locationManager
    }

    func configure(modelContext: ModelContext) {
        guard locationRepository == nil else {
            return
        }

        let localDataSource = LocationLocalDataSource(modelContext: modelContext)
        locationRepository = LocationRepository(localDataSource: localDataSource)
    }

    func onSwapRouteClick() {
        let from = uiState.from
        uiState.from = uiState.to
        uiState.to = from
    }

    func onDateSelected(_ date: Date) {
        uiState.selectedDate = date
    }

    func onDateTypeChanged(_ type: DateTimeType) {
        uiState.dateType = type
    }

    func onPassengersClick() {
        print("Passengers row tapped")
    }

    func onOptionsClick() {
        print("Options row tapped")
    }

    func onConnectionTypeClick() {
        print("Fastest connections row tapped")
    }

    func onSearchClick() {
        guard let from = uiState.fromLocation, let to = uiState.toLocation else { return }
        journeySearchParams = JourneySearchParams(
            from: from,
            to: to,
            date: uiState.selectedDate,
            passengers: 1
        )
        shouldNavigateToResults = true
    }

    func onLocationPickerOpened(for field: LocationPickerField) {
        locationSearchTask?.cancel()
        uiState.locationPicker = LocationPickerUiState(
            searchText: "",
            results: cachedLocations(),
            favoriteLocationIDs: cachedLocationIDs(),
            selectedField: field
        )
    }

    func onLocationSearchChange(_ value: String) {
        uiState.locationPicker.searchText = value
        locationSearchTask?.cancel()

        let query = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else {
            uiState.locationPicker.results = cachedLocations()
            uiState.locationPicker.favoriteLocationIDs = cachedLocationIDs()
            uiState.locationPicker.errorMessage = nil
            uiState.locationPicker.isLoading = false
            return
        }

        uiState.locationPicker.results = cachedLocations()
        uiState.locationPicker.favoriteLocationIDs = cachedLocationIDs()

        locationSearchTask = Task {
            uiState.locationPicker.isLoading = true
            uiState.locationPicker.errorMessage = nil

            do {
                try await Task.sleep(nanoseconds: Self.searchDebounceNanoseconds)
                try Task.checkCancellation()

                let locations = try await searchLocations(query: query)
                try Task.checkCancellation()

                uiState.locationPicker.results = locations
                uiState.locationPicker.favoriteLocationIDs = cachedLocationIDs()
                uiState.locationPicker.isLoading = false
            } catch is CancellationError {
                // A newer search replaced this one.
            } catch {
                uiState.locationPicker.errorMessage = locationSearchMessage(for: error)
                uiState.locationPicker.results = cachedLocations()
                uiState.locationPicker.favoriteLocationIDs = cachedLocationIDs()
                uiState.locationPicker.isLoading = false
            }
        }
    }

    private func getCurrentLocation(latitude: String, longitude: String) {
        locationSearchTask?.cancel()

        locationSearchTask = Task {
            uiState.locationPicker.isLoading = true
            uiState.locationPicker.errorMessage = nil

            do {
                let locations = try await currentLocations(
                    latitude: latitude,
                    longitude: longitude
                )

                try Task.checkCancellation()

                uiState.locationPicker.results = locations
                uiState.locationPicker.favoriteLocationIDs = cachedLocationIDs()
                uiState.locationPicker.isLoading = false
            } catch is CancellationError {
                // A newer search replaced this one.
            } catch {
                uiState.locationPicker.errorMessage = locationSearchMessage(for: error)
                uiState.locationPicker.results = cachedLocations()
                uiState.locationPicker.favoriteLocationIDs = cachedLocationIDs()
                uiState.locationPicker.isLoading = false
            }
        }
    }

    func onClickCurrentPosition() {
        Task {
            do {
                let coordinate = try await locationManager.requestCurrentLocation()

                getCurrentLocation(
                    latitude: String(coordinate.latitude),
                    longitude: String(coordinate.longitude)
                )
            } catch {
                uiState.locationPicker.errorMessage = "Could not get current location"
                uiState.locationPicker.results = cachedLocations()
                uiState.locationPicker.favoriteLocationIDs = cachedLocationIDs()
                uiState.locationPicker.isLoading = false
            }
        }
    }

    func onLocationSelected(_ location: SearchStationModelElement) {
        locationSearchTask?.cancel()

        switch uiState.locationPicker.selectedField {
        case .origin:
            uiState.from = location.name
            uiState.fromLocation = location
        case .destination:
            uiState.to = location.name
            uiState.toLocation = location
        }

        // Cache the selected station so it appears in future searches offline.
        try? locationRepository?.saveLocation(location)
        uiState.locationPicker.favoriteLocationIDs = cachedLocationIDs()
    }

    func onSaveLocationClick(_ location: SearchStationModelElement) {
        do {
            try locationRepository?.saveLocation(location)
            uiState.locationPicker.favoriteLocationIDs = cachedLocationIDs()
            if uiState.locationPicker.searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                uiState.locationPicker.results = cachedLocations()
            }
        } catch {
            uiState.locationPicker.errorMessage = "Could not save location"
        }
    }

    deinit {
        locationSearchTask?.cancel()
    }

    private func locationSearchMessage(for error: Error) -> String {
        if let urlError = error as? URLError {
            switch urlError.code {
            case .notConnectedToInternet, .networkConnectionLost, .cannotConnectToHost, .cannotFindHost, .timedOut:
                return "No internet connection or server is down"
            default:
                return "Could not load locations"
            }
        }

        if case APIError.statusCode = error {
            return "Server is down"
        }

        return "Could not load locations"
    }

    private func searchLocations(query: String) async throws -> [SearchStationModelElement] {
        if let locationRepository {
            return try await locationRepository.searchLocations(query: query)
        }

        return try await LocationService().searchLocations(query: query)
    }

    private func currentLocations(
        latitude: String,
        longitude: String
    ) async throws -> [SearchStationModelElement] {
        if let locationRepository {
            return try await locationRepository.getCurrentLocation(
                latitude: latitude,
                longitude: longitude
            )
        }

        return try await LocationService().getCurrentLocation(
            latitude: latitude,
            longitude: longitude
        )
    }

    private func cachedLocations() -> [SearchStationModelElement] {
        (try? locationRepository?.cachedLocations()) ?? []
    }

    private func cachedLocationIDs() -> Set<String> {
        Set(cachedLocations().map(\.displayID))
    }
}

enum DateTimeType: Equatable {
    case departure, arrival
}

struct SearchJourneyUiState {
    var from = ""
    var to = ""
    var fromLocation: SearchStationModelElement?
    var toLocation: SearchStationModelElement?
    var selectedDate: Date = Date()
    var dateType: DateTimeType = .departure
    var passengers = "1 pers. | 2nd Cl."
    var options = "Means of transport"
    var connectionType = "Fastest Route"

    var locationPicker = LocationPickerUiState()

    var dateDisplayString: String {
        let time = selectedDate.formatted(date: .omitted, time: .shortened)
        if Calendar.current.isDateInToday(selectedDate) {
            return "Today, \(time)"
        } else if Calendar.current.isDateInTomorrow(selectedDate) {
            return "Tomorrow, \(time)"
        } else {
            let dayMonth = selectedDate.formatted(.dateTime.weekday(.abbreviated).day().month(.abbreviated))
            return "\(dayMonth), \(time)"
        }
    }
}

struct LocationPickerUiState {
    var searchText = ""
    var results: [SearchStationModelElement] = []
    var favoriteLocationIDs: Set<String> = []
    var isLoading = false
    var errorMessage: String?
    var selectedField: LocationPickerField = .origin

    var title: String {
        selectedField.title
    }
}
