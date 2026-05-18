//
//  APIEndpoint.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 9/5/26.
//

import Foundation

struct APIEndpoint {
    let path: String
    let queryItems: [URLQueryItem]

    static func locations(query: String) -> APIEndpoint {
        APIEndpoint(
            path: "locations",
            queryItems: [
                URLQueryItem(name: "query", value: query),
                URLQueryItem(name: "results", value: "10"),
                URLQueryItem(name: "stops", value: "true"),
                URLQueryItem(name: "addresses", value: "true"),
                URLQueryItem(name: "poi", value: "true")
            ]
        )
    }
    
    static func getCurrentPosition(latitude: String, longitude: String) -> APIEndpoint {
        APIEndpoint(
            path: "locations/nearby",
            queryItems: [
                URLQueryItem(name: "latitude", value: latitude),
                URLQueryItem(name: "longitude", value: longitude),
                URLQueryItem(name: "distance", value: "1000"),
                URLQueryItem(name: "results", value: "10"),
                URLQueryItem(name: "stops", value: "true"),
                URLQueryItem(name: "addresses", value: "true"),
                URLQueryItem(name: "poi", value: "true")
            ]
        )
    }

    static func journeys(params: JourneySearchParams) -> APIEndpoint {
        var items: [URLQueryItem] = [
            URLQueryItem(name: "from", value: params.from.id ?? ""),
            URLQueryItem(name: "to", value: params.to.id ?? ""),
            URLQueryItem(name: "departure", value: ISO8601DateFormatter().string(from: params.date)),
            URLQueryItem(name: "results", value: String(10)),
            URLQueryItem(name: "nationalExpress", value: String(params.products.nationalExpress)),
            URLQueryItem(name: "national", value: String(params.products.national)),
            URLQueryItem(name: "regionalExpress", value: String(params.products.regionalExpress)),
            URLQueryItem(name: "regional", value: String(params.products.regional)),
            URLQueryItem(name: "suburban", value: String(params.products.suburban)),
            URLQueryItem(name: "subway", value: String(params.products.subway)),
            URLQueryItem(name: "tram", value: String(params.products.tram)),
            URLQueryItem(name: "bus", value: String(params.products.bus)),
            URLQueryItem(name: "ferry", value: String(params.products.ferry)),
            URLQueryItem(name: "taxi", value: String(params.products.taxi))
        ]
//        if let loyaltyCard = params.loyaltyCard {
//            items.append(URLQueryItem(name: "loyaltyCard[type]", value: loyaltyCard.type.rawValue))
//        }
        return APIEndpoint(path: "journeys", queryItems: items)
    }
}
