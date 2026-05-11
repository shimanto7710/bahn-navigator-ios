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

    static func journeys(fromID: String, toID: String, departure: Date) -> APIEndpoint {
        APIEndpoint(
            path: "journeys",
            queryItems: [
                URLQueryItem(name: "from", value: fromID),
                URLQueryItem(name: "to", value: toID),
                URLQueryItem(name: "departure", value: ISO8601DateFormatter().string(from: departure)),
                URLQueryItem(name: "results", value: "6")
            ]
        )
    }
}
