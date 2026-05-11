//
//  BahnNavigatorTests.swift
//  BahnNavigatorTests
//
//  Created by Shimanto A. on 8/5/26.
//

import Foundation
import Testing
@testable import BahnNavigator

// MARK: - JourneyResultsViewModel

@MainActor
struct JourneyResultsViewModelTests {

    @Test
    func loadPopulatesJourneysOnSuccess() async {
        let stub = StubJourneyService(result: .success([Journey.fixture()]))
        let viewModel = JourneyResultsViewModel(
            params: .fixture(),
            service: stub
        )

        await viewModel.load()

        #expect(viewModel.uiState.journeys.count == 1)
        #expect(viewModel.uiState.errorMessage == nil)
        #expect(viewModel.uiState.isLoading == false)
    }

    @Test
    func loadSetsErrorMessageOnFailure() async {
        let stub = StubJourneyService(result: .failure(APIError.statusCode(500)))
        let viewModel = JourneyResultsViewModel(
            params: .fixture(),
            service: stub
        )

        await viewModel.load()

        #expect(viewModel.uiState.journeys.isEmpty)
        #expect(viewModel.uiState.errorMessage == "Could not load journeys")
        #expect(viewModel.uiState.isLoading == false)
    }

    @Test
    func loadIgnoresCancellationError() async {
        let stub = StubJourneyService(result: .failure(CancellationError()))
        let viewModel = JourneyResultsViewModel(
            params: .fixture(),
            service: stub
        )

        await viewModel.load()

        #expect(viewModel.uiState.errorMessage == nil)
    }
}

// MARK: - LocationRepository

@MainActor
struct LocationRepositoryTests {

    @Test
    func cachedLocationsDelegatesToLocalDataSource() throws {
        let cached = [SearchStationModelElement.fixture(id: "BLN", name: "Berlin Hbf")]
        let local = StubLocalDataSource(cached: cached)
        let remote = StubLocationService()
        let repository = LocationRepository(remoteService: remote, localDataSource: local)

        let result = try repository.cachedLocations()

        #expect(result.count == 1)
        #expect(result.first?.name == "Berlin Hbf")
        #expect(remote.searchCallCount == 0)
    }

    @Test
    func searchLocationsCallsRemoteService() async throws {
        let local = StubLocalDataSource()
        let remote = StubLocationService(
            searchResult: [SearchStationModelElement.fixture(id: "MUC", name: "München Hbf")]
        )
        let repository = LocationRepository(remoteService: remote, localDataSource: local)

        let result = try await repository.searchLocations(query: "Münch")

        #expect(remote.searchCallCount == 1)
        #expect(remote.lastQuery == "Münch")
        #expect(result.first?.name == "München Hbf")
    }

    @Test
    func saveLocationPersistsViaLocalDataSource() throws {
        let local = StubLocalDataSource()
        let repository = LocationRepository(
            remoteService: StubLocationService(),
            localDataSource: local
        )
        let location = SearchStationModelElement.fixture(id: "FRA", name: "Frankfurt Hbf")

        try repository.saveLocation(location)

        #expect(local.savedLocations.count == 1)
        #expect(local.savedLocations.first?.id == "FRA")
    }
}

// MARK: - TransportProduct

struct TransportProductTests {

    @Test
    func unknownRawValueDecodesAsUnknown() throws {
        let json = Data(#""flyingCarpet""#.utf8)
        let product = try JSONDecoder().decode(TransportProduct.self, from: json)
        #expect(product == .unknown)
    }

    @Test
    func knownRawValueDecodesCorrectly() throws {
        let json = Data(#""nationalExpress""#.utf8)
        let product = try JSONDecoder().decode(TransportProduct.self, from: json)
        #expect(product == .nationalExpress)
    }
}

// MARK: - Test doubles

private final class StubJourneyService: JourneyServiceProtocol, @unchecked Sendable {
    private let result: Result<[Journey], Error>

    init(result: Result<[Journey], Error>) {
        self.result = result
    }

    func searchJourneys(params: JourneySearchParams) async throws -> [Journey] {
        try result.get()
    }
}

@MainActor
private final class StubLocationService: LocationServiceProtocol {
    private(set) var searchCallCount = 0
    private(set) var lastQuery: String?
    private let searchResult: [SearchStationModelElement]

    init(searchResult: [SearchStationModelElement] = []) {
        self.searchResult = searchResult
    }

    func searchLocations(query: String) async throws -> [SearchStationModelElement] {
        searchCallCount += 1
        lastQuery = query
        return searchResult
    }

    func getCurrentLocation(latitude: String, longitude: String) async throws -> [SearchStationModelElement] {
        []
    }
}

@MainActor
private final class StubLocalDataSource: LocationLocalDataSourceProtocol {
    var cached: [SearchStationModelElement]
    private(set) var savedLocations: [SearchStationModelElement] = []

    init(cached: [SearchStationModelElement] = []) {
        self.cached = cached
    }

    func save(_ location: SearchStationModelElement) throws {
        savedLocations.append(location)
    }

    func fetchLocations() throws -> [SearchStationModelElement] {
        cached
    }
}

// MARK: - Fixtures

private extension SearchStationModelElement {
    static func fixture(
        id: String? = "TEST",
        name: String = "Test Station"
    ) -> SearchStationModelElement {
        SearchStationModelElement(
            id: id,
            name: name,
            type: .station,
            location: nil,
            products: nil,
            weight: nil,
            ril100IDS: nil,
            ifoptID: nil,
            priceCategory: nil,
            transitAuthority: nil,
            stadaID: nil,
            station: nil
        )
    }
}

private extension JourneySearchParams {
    static func fixture() -> JourneySearchParams {
        JourneySearchParams(
            from: SearchStationModelElement.fixture(id: "BLN", name: "Berlin Hbf"),
            to: SearchStationModelElement.fixture(id: "MUC", name: "München Hbf"),
            date: Date(timeIntervalSince1970: 1_780_000_000),
            passengers: 1
        )
    }
}

private extension Journey {
    /// Build a Journey via JSON since its memberwise init is not synthesized.
    static func fixture() -> Journey {
        let json = """
        {
          "refreshToken": "tok-1",
          "legs": [
            {
              "tripId": "leg-1",
              "origin": "Berlin Hbf",
              "destination": "München Hbf",
              "departure": "2026-05-20T08:00:00Z",
              "arrival": "2026-05-20T12:13:00Z",
              "lineName": "ICE 503",
              "product": "nationalExpress"
            }
          ]
        }
        """
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try! decoder.decode(Journey.self, from: Data(json.utf8))
    }
}
