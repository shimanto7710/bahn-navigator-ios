//
//  JourneyModel.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 11/5/26.
//

import Foundation

// MARK: - Journey

struct Journey: Identifiable, Decodable {
    let id: String
    let legs: [JourneyLeg]

    var departure: Date { legs.first?.departure ?? Date() }
    var arrival: Date { legs.last?.arrival ?? Date() }
    var origin: String { legs.first?.origin ?? "" }
    var destination: String { legs.last?.destination ?? "" }
    var durationMinutes: Int { Int(arrival.timeIntervalSince(departure) / 60) }
    var changes: Int { max(0, legs.count - 1) }

    var formattedDuration: String {
        let h = durationMinutes / 60
        let m = durationMinutes % 60
        return h > 0 ? "\(h)h \(m)min" : "\(m)min"
    }

    private enum CodingKeys: String, CodingKey {
        case id = "refreshToken"
        case legs
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? container.decode(String.self, forKey: .id)) ?? UUID().uuidString
        legs = try container.decode([JourneyLeg].self, forKey: .legs)
    }
}

// MARK: - JourneyLeg

struct JourneyLeg: Identifiable, Decodable {
    let id: String
    let origin: String
    let destination: String
    let departure: Date
    let arrival: Date
    let lineName: String?
    let product: TransportProduct

    private enum CodingKeys: String, CodingKey {
        case id = "tripId"
        case origin, destination, departure, arrival, lineName, product
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = (try? container.decode(String.self, forKey: .id)) ?? UUID().uuidString
        origin = try container.decode(String.self, forKey: .origin)
        destination = try container.decode(String.self, forKey: .destination)
        departure = try container.decode(Date.self, forKey: .departure)
        arrival = try container.decode(Date.self, forKey: .arrival)
        lineName = try container.decodeIfPresent(String.self, forKey: .lineName)
        product = try container.decode(TransportProduct.self, forKey: .product)
    }
}

// MARK: - TransportProduct

enum TransportProduct: String, Decodable {
    case nationalExpress, national, regionalExpress, regional
    case suburban, bus, ferry, subway, tram, taxi, unknown

    /// Tolerates unknown product strings rather than failing the whole decode.
    init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = TransportProduct(rawValue: raw) ?? .unknown
    }

    var sfSymbol: String {
        switch self {
        case .nationalExpress, .national:           return "train.side.front.car"
        case .regionalExpress, .regional:           return "tram.fill"
        case .suburban:                             return "tram.circle.fill"
        case .bus:                                  return "bus.fill"
        case .ferry:                                return "ferry.fill"
        case .subway:                               return "train.side.middle.car"
        case .tram:                                 return "tram"
        case .taxi:                                 return "car.fill"
        case .unknown:                              return "train.side.front.car"
        }
    }
}

// MARK: - JourneySearchParams

struct JourneySearchParams {
    let from: SearchStationModelElement
    let to: SearchStationModelElement
    let date: Date
    let passengers: Int
}
