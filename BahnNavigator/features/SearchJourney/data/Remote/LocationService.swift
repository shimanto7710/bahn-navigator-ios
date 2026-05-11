//
//  LocationService.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 9/5/26.
//

import Foundation

protocol LocationServiceProtocol {
    func searchLocations(query: String) async throws -> [SearchStationModelElement]
    func getCurrentLocation(latitude: String, longitude: String) async throws -> [SearchStationModelElement]
}

final class LocationService: LocationServiceProtocol {
    private let apiClient: APIClient

    init(apiClient: APIClient = APIClient()) {
        self.apiClient = apiClient
    }

    func searchLocations(query: String) async throws -> [SearchStationModelElement] {
        try await apiClient.request(.locations(query: query))
    }
    
    func getCurrentLocation(latitude: String, longitude: String) async throws -> [SearchStationModelElement] {
        try await apiClient.request(.getCurrentPosition(latitude: latitude, longitude:longitude))
    }
}
