//
//  LocationManager.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 11/5/26.
//

import CoreLocation

protocol LocationManaging {
    func requestCurrentLocation() async throws -> CLLocationCoordinate2D
}

final class LocationManager: NSObject, CLLocationManagerDelegate, LocationManaging {
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocationCoordinate2D, Error>?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestCurrentLocation() async throws -> CLLocationCoordinate2D {
        let status = manager.authorizationStatus

        if status == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }

        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            manager.requestLocation()
        }
    }

    func locationManager(
        _ manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation]
    ) {
        guard let coordinate = locations.last?.coordinate else {
            continuation?.resume(throwing: URLError(.badServerResponse))
            continuation = nil
            return
        }

        continuation?.resume(returning: coordinate)
        continuation = nil
    }

    func locationManager(
        _ manager: CLLocationManager,
        didFailWithError error: Error
    ) {
        continuation?.resume(throwing: error)
        continuation = nil
    }
}
