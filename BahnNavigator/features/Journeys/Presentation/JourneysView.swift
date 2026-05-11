//
//  JourneysView.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 11/5/26.
//

import SwiftUI
import SwiftData

struct JourneysView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel = JourneysViewModel()

    var body: some View {
        NavigationStack {
            Group {
                if viewModel.savedJourneys.isEmpty {
                    emptyState
                } else {
                    journeyList
                }
            }
            .navigationTitle("My Journeys")
        }
        .onAppear {
            viewModel.configure(modelContext: modelContext)
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 52))
                .foregroundColor(.secondary)

            Text("No saved journeys")
                .font(.headline)

            Text("Search for a connection to get started")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Journey list

    private var journeyList: some View {
        List {
            ForEach(viewModel.savedJourneys) { journey in
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 6) {
                        Text(journey.fromName)
                            .font(.headline)
                            .lineLimit(1)
                        Image(systemName: "arrow.right")
                            .font(.caption.weight(.bold))
                            .foregroundColor(.secondary)
                        Text(journey.toName)
                            .font(.headline)
                            .lineLimit(1)
                    }
                    Text(journey.departureDate, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding(.vertical, 4)
            }
            .onDelete(perform: viewModel.delete)
        }
        .listStyle(.insetGrouped)
        .toolbar {
            EditButton()
        }
    }
}
