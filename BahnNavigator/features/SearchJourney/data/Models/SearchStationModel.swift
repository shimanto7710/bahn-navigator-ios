//
//  SearchStationModel.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 9/5/26.
//

import Foundation

// MARK: - SearchStationModelElement
class SearchStationModelElement: Codable {
    let id: String?
    let name: String
    let type: SearchStationModelType
    let location: Location?
    let products: Products?
    let weight: Double?
    let ril100IDS: [String]?
    let ifoptID: String?
    let priceCategory: Int?
    let transitAuthority, stadaID: String?
    let station: SearchStationModelElement?
    let latitude, longitude: Double?
    let address: String?
    let poi: Bool?

    var displayID: String {
        if let id {
            return id
        }

        let latitude = latitude ?? location?.latitude ?? 0
        let longitude = longitude ?? location?.longitude ?? 0
        return "\(name)-\(latitude)-\(longitude)"
    }

    enum CodingKeys: String, CodingKey {
        case id, name, type, location, products, weight
        case ril100IDS = "ril100Ids"
        case ifoptID = "ifoptId"
        case priceCategory, transitAuthority
        case stadaID = "stadaId"
        case station
        case latitude, longitude, address, poi
    }

    init(
        id: String?,
        name: String,
        type: SearchStationModelType,
        location: Location?,
        products: Products?,
        weight: Double?,
        ril100IDS: [String]?,
        ifoptID: String?,
        priceCategory: Int?,
        transitAuthority: String?,
        stadaID: String?,
        station: SearchStationModelElement?,
        latitude: Double? = nil,
        longitude: Double? = nil,
        address: String? = nil,
        poi: Bool? = nil
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.location = location
        self.products = products
        self.weight = weight
        self.ril100IDS = ril100IDS
        self.ifoptID = ifoptID
        self.priceCategory = priceCategory
        self.transitAuthority = transitAuthority
        self.stadaID = stadaID
        self.station = station
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.poi = poi
    }
}

// MARK: - Location
struct Location: Codable {
    let type: LocationType
    let id: String?
    let latitude, longitude: Double
}

enum LocationType: String, Codable {
    case location = "location"
}

// MARK: - Products
struct Products: Codable {
    let nationalExpress, national, regionalExpress, regional: Bool
    let suburban, bus, ferry, subway: Bool
    let tram, taxi: Bool
}

enum SearchStationModelType: String, Codable {
    case location = "location"
    case station = "station"
    case stop = "stop"
}

typealias SearchStationModel = [SearchStationModelElement]

// MARK: - Hashable

extension SearchStationModelElement: Hashable {
    static func == (lhs: SearchStationModelElement, rhs: SearchStationModelElement) -> Bool {
        lhs.displayID == rhs.displayID
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(displayID)
    }
}
