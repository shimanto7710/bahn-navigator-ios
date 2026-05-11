//
//  JourneyService.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 11/5/26.
//

import Foundation

protocol JourneyServiceProtocol {
    func searchJourneys(params: JourneySearchParams) async throws -> [Journey]
}

/// Wraps the `/journeys` endpoint from the project API.
/// The API itself is built separately and hosted at `AppConfiguration.baseURL`.
final class JourneyService: JourneyServiceProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }

    func searchJourneys(params: JourneySearchParams) async throws -> [Journey] {
        let response: JourneysResponse = try await apiClient.request(
            .journeys(
                fromID: params.from.id ?? "",
                toID: params.to.id ?? "",
                departure: params.date
            )
        )
        return response.journeys
    }
}

/// Matches the typical HAFAS-style envelope: `{ "journeys": [...] }`.
/// Adjust this if your API returns a bare array instead.
struct JourneysResponse: Decodable {
    let journeys: [Journey]
}
