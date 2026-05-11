//
//  LocationLocalDataSource.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 11/5/26.
//

import Foundation
import SwiftData

@MainActor
protocol LocationLocalDataSourceProtocol {
    func save(_ location: SearchStationModelElement) throws
    func fetchLocations() throws -> [SearchStationModelElement]
}

@MainActor
final class LocationLocalDataSource: LocationLocalDataSourceProtocol {
    private let modelContext: ModelContext
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    func save(_ location: SearchStationModelElement) throws {
        let rawData = try encoder.encode(location)
        let entity = try findEntity(id: location.displayID) ?? CachedLocationEntity(
            id: location.displayID,
            name: location.name,
            type: location.type.rawValue,
            latitude: location.location?.latitude ?? location.latitude,
            longitude: location.location?.longitude ?? location.longitude,
            rawData: rawData
        )

        entity.name = location.name
        entity.type = location.type.rawValue
        entity.latitude = location.location?.latitude ?? location.latitude
        entity.longitude = location.location?.longitude ?? location.longitude
        entity.rawData = rawData
        entity.savedAt = Date()

        if entity.modelContext == nil {
            modelContext.insert(entity)
        }

        try modelContext.save()
    }

    func fetchLocations() throws -> [SearchStationModelElement] {
        let descriptor = FetchDescriptor<CachedLocationEntity>(
            sortBy: [SortDescriptor(\.savedAt, order: .reverse)]
        )

        return try modelContext.fetch(descriptor).map { entity in
            if let rawData = entity.rawData,
               let location = try? decoder.decode(SearchStationModelElement.self, from: rawData) {
                return location
            }

            return entity.toSearchStationModelElement()
        }
    }

    private func findEntity(id: String) throws -> CachedLocationEntity? {
        let descriptor = FetchDescriptor<CachedLocationEntity>(
            predicate: #Predicate { entity in
                entity.id == id
            }
        )

        return try modelContext.fetch(descriptor).first
    }
}

private extension CachedLocationEntity {
    func toSearchStationModelElement() -> SearchStationModelElement {
        let locationType = SearchStationModelType(rawValue: type) ?? .station

        return SearchStationModelElement(
            id: id,
            name: name,
            type: locationType,
            location: Location(
                type: .location,
                id: id,
                latitude: latitude ?? 0,
                longitude: longitude ?? 0
            ),
            products: nil,
            weight: nil,
            ril100IDS: nil,
            ifoptID: nil,
            priceCategory: nil,
            transitAuthority: nil,
            stadaID: nil,
            station: nil,
            latitude: latitude,
            longitude: longitude
        )
    }
}
