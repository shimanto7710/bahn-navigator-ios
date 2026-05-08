//
//  SearchJourneyViewModel.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 8/5/26.
//

import Combine
import Foundation

final class SearchJourneyViewModel: ObservableObject {
    @Published private(set) var uiState = SearchJourneyUiState()

    func onFromChange(_ value: String) {
        uiState.from = value
    }

    func onToChange(_ value: String) {
        uiState.to = value
    }

    func onSwapRouteClick() {
        let from = uiState.from
        uiState.from = uiState.to
        uiState.to = from
    }

    func onDateClick() {
        print("Date row tapped")
    }

    func onPassengersClick() {
        print("Passengers row tapped")
    }

    func onOptionsClick() {
        print("Options row tapped")
    }

    func onConnectionTypeClick() {
        print("Fastest connections row tapped")
    }

    func onSearchClick() {
        print("On Tap Search Button")
    }
}

struct SearchJourneyUiState {
    var from = ""
    var to = ""
    var date = "Today, 12:17"
    var passengers = "1 pers. | 2nd Cl."
    var options = "Means of transport"
    var connectionType = "Fastest Route"
}
