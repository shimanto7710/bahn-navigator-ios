//
//  JourneysViewModel.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 11/5/26.
//

import Foundation
import SwiftData

@MainActor
final class SavedJourneysViewModel: ObservableObject {
    @Published private(set) var savedJourneys: [SavedJourneyEntity] = []
    @Published private(set) var errorMessage: String?

    private var modelContext: ModelContext?

    func configure(modelContext: ModelContext) {
        self.modelContext = modelContext
        loadJourneys()
    }

    func delete(at offsets: IndexSet) {
        guard let modelContext else { return }
        offsets.forEach { index in
            modelContext.delete(savedJourneys[index])
        }
        do {
            try modelContext.save()
            loadJourneys()
        } catch {
            // Roll back the in-memory deletions so the list stays consistent with disk.
            modelContext.rollback()
            loadJourneys()
            errorMessage = "Could not delete journey. Please try again."
        }
    }

    private func loadJourneys() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<SavedJourneyEntity>(
            sortBy: [SortDescriptor(\.savedAt, order: .reverse)]
        )
        do {
            savedJourneys = try modelContext.fetch(descriptor)
            errorMessage = nil
        } catch {
            errorMessage = "Could not load saved journeys."
        }
    }
}
