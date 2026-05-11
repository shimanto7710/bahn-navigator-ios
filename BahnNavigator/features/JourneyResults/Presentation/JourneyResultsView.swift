//
//  JourneyResultsView.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 11/5/26.
//

import SwiftUI

struct JourneyResultsView: View {
    @StateObject private var viewModel: JourneyResultsViewModel
    private let params: JourneySearchParams

    init(params: JourneySearchParams) {
        self.params = params
        _viewModel = StateObject(wrappedValue: JourneyResultsViewModel(params: params))
    }

    var body: some View {
        Group {
            if viewModel.uiState.isLoading {
                LoadingView()
            } else if let error = viewModel.uiState.errorMessage {
                ErrorView(message: error) {
                    Task { await viewModel.load() }
                }
            } else if viewModel.uiState.journeys.isEmpty {
                ErrorView(message: "No connections found for this route") {
                    Task { await viewModel.load() }
                }
            } else {
                journeyList
            }
        }
        .navigationTitle("Connections")
        .navigationBarTitleDisplayMode(.inline)
        .task { await viewModel.load() }
    }

    // MARK: - Journey list

    private var journeyList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                routeHeader
                ForEach(viewModel.uiState.journeys) { journey in
                    JourneyCard(journey: journey)
                }
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
    }

    // MARK: - Route header

    private var routeHeader: some View {
        HStack(alignment: .center, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(params.from.name)
                    .font(.headline)
                    .lineLimit(1)
                Image(systemName: "arrow.down")
                    .font(.caption.weight(.bold))
                    .foregroundColor(.secondary)
                Text(params.to.name)
                    .font(.headline)
                    .lineLimit(1)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(params.date, style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("\(params.passengers) pax")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

// MARK: - JourneyCard

private struct JourneyCard: View {
    let journey: Journey

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            timingRow
            legRow
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: .black.opacity(0.06), radius: 4, y: 2)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityDescription)
    }

    /// VoiceOver-friendly single-string summary so the row is read as one unit
    /// rather than as a stream of disjointed labels.
    private var accessibilityDescription: String {
        let depart = journey.departure.formatted(date: .omitted, time: .shortened)
        let arrive = journey.arrival.formatted(date: .omitted, time: .shortened)
        let changeText = journey.changes == 0
            ? "direct"
            : "\(journey.changes) change\(journey.changes > 1 ? "s" : "")"
        return "Departs \(depart), arrives \(arrive), duration \(journey.formattedDuration), \(changeText)"
    }

    // MARK: Departure / duration / arrival

    private var timingRow: some View {
        HStack {
            Text(journey.departure.formatted(date: .omitted, time: .shortened))
                .font(.title3.weight(.semibold))

            Spacer()

            VStack(spacing: 4) {
                Text(journey.formattedDuration)
                    .font(.caption)
                    .foregroundColor(.secondary)
                legDots
            }

            Spacer()

            Text(journey.arrival.formatted(date: .omitted, time: .shortened))
                .font(.title3.weight(.semibold))
        }
    }

    // MARK: Leg dots connector

    private var legDots: some View {
        HStack(spacing: 0) {
            ForEach(Array(journey.legs.enumerated()), id: \.offset) { index, _ in
                Circle()
                    .fill(Color.appDark)
                    .frame(width: 8, height: 8)
                if index < journey.legs.count - 1 {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.35))
                        .frame(width: 24, height: 1)
                }
            }
        }
    }

    // MARK: Line badges + change count

    private var legRow: some View {
        HStack(spacing: 6) {
            ForEach(journey.legs) { leg in
                if let line = leg.lineName {
                    HStack(spacing: 4) {
                        Image(systemName: leg.product.sfSymbol)
                            .font(.caption2)
                        Text(line)
                            .font(.caption2.weight(.medium))
                    }
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color.appDark)
                    .foregroundColor(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                }
            }

            Spacer()

            if journey.changes == 0 {
                Text("Direct")
                    .font(.caption.weight(.medium))
                    .foregroundColor(.green)
            } else {
                Text("\(journey.changes) change\(journey.changes > 1 ? "s" : "")")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}
