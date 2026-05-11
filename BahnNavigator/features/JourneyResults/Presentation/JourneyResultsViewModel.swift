//
//  JourneyResultsViewModel.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 11/5/26.
//

import Foundation

@MainActor
final class JourneyResultsViewModel: ObservableObject {
    @Published private(set) var uiState = JourneyResultsUiState()

    private let params: JourneySearchParams
    private let service: JourneyServiceProtocol

    init(
        params: JourneySearchParams,
        service: JourneyServiceProtocol = JourneyService()
    ) {
        self.params = params
        self.service = service
    }

    /// Driven by `.task` in the view — auto-cancels when the view disappears.
    func load() async {
        uiState.isLoading = true
        uiState.errorMessage = nil

        do {
            uiState.journeys = try await service.searchJourneys(params: params)
        } catch is CancellationError {
            return
        } catch {
            uiState.errorMessage = "Could not load journeys"
        }

        uiState.isLoading = false
    }
}

struct JourneyResultsUiState {
    var journeys: [Journey] = []
    var isLoading = false
    var errorMessage: String?
}
