//
//  JourneysViewModel.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 11/5/26.
//

import Foundation
import SwiftData

@MainActor
final class JourneysViewModel: ObservableObject {
    @Published private(set) var savedJourneys: [SavedJourneyEntity] = []

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
        } catch {
            assertionFailure("Failed to delete saved journey: \(error)")
        }
        loadJourneys()
    }

    private func loadJourneys() {
        guard let modelContext else { return }
        let descriptor = FetchDescriptor<SavedJourneyEntity>(
            sortBy: [SortDescriptor(\.savedAt, order: .reverse)]
        )
        savedJourneys = (try? modelContext.fetch(descriptor)) ?? []
    }
}
