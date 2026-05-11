//
//  LocationRepository.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 11/5/26.
//

import Foundation

@MainActor
protocol LocationRepositoryProtocol {
    func cachedLocations() throws -> [SearchStationModelElement]
    func saveLocation(_ location: SearchStationModelElement) throws
    func searchLocations(query: String) async throws -> [SearchStationModelElement]
    func getCurrentLocation(latitude: String, longitude: String) async throws -> [SearchStationModelElement]
}

@MainActor
final class LocationRepository: LocationRepositoryProtocol {
    private let remoteService: LocationServiceProtocol
    private let localDataSource: LocationLocalDataSourceProtocol

    init(
        remoteService: LocationServiceProtocol = LocationService(),
        localDataSource: LocationLocalDataSourceProtocol
    ) {
        self.remoteService = remoteService
        self.localDataSource = localDataSource
    }

    func cachedLocations() throws -> [SearchStationModelElement] {
        try localDataSource.fetchLocations()
    }

    func saveLocation(_ location: SearchStationModelElement) throws {
        try localDataSource.save(location)
    }

    func searchLocations(query: String) async throws -> [SearchStationModelElement] {
        try await remoteService.searchLocations(query: query)
    }

    func getCurrentLocation(latitude: String, longitude: String) async throws -> [SearchStationModelElement] {
        try await remoteService.getCurrentLocation(
            latitude: latitude,
            longitude: longitude
        )
    }
}
