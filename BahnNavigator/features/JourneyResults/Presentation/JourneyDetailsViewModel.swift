//
//  JourneyResultsViewModel.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 11/5/26.
//

import Foundation
import SwiftData

@MainActor
final class JourneyDetailsViewModel: ObservableObject {
    @Published private(set) var uiState = JourneyResultsUiState()

    private let params: JourneySearchParams
    private let service: JourneyServiceProtocol
    private var modelContext: ModelContext?

    init(
        params: JourneySearchParams,
        service: JourneyServiceProtocol = JourneyService()
    ) {
        self.params = params
        self.service = service
    }

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
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

    func saveJourney(_ journey: Journey) {
        guard let modelContext else { return }

        // Avoid duplicate saves — skip silently if already saved.
        let id = journey.id
        let existing = FetchDescriptor<SavedJourneyEntity>(
            predicate: #Predicate { $0.id == id }
        )
        guard (try? modelContext.fetchCount(existing)) == 0 else { return }

        let entity = SavedJourneyEntity(
            id: journey.id,
            fromName: journey.origin,
            toName: journey.destination,
            departureDate: journey.departure
        )
        modelContext.insert(entity)

        do {
            try modelContext.save()
            uiState.savedJourneyIDs.insert(journey.id)
        } catch {
            modelContext.delete(entity)
        }
    }
}

struct JourneyResultsUiState {
    var journeys: [Journey] = []
    var isLoading = false
    var errorMessage: String?
    var savedJourneyIDs: Set<String> = []
}
