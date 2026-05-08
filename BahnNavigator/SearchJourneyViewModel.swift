//
//  SearchJourneyViewModel.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 8/5/26.
//

import Combine
import Foundation

final class SearchJourneyViewModel: ObservableObject {
    @Published var fromText = ""
    @Published var toText = ""

    @Published var dateText = "Today, 12:17"
    @Published var passengersText = "1 pers. | 2nd Cl."
    @Published var optionsText = "Means of transport: Local/regi..."
    @Published var connectionTypeText = "Active"

    func onDateTapped() {
        print("Date row tapped")
    }

    func onPassengersTapped() {
        print("Passengers row tapped")
    }

    func onOptionsTapped() {
        print("Options row tapped")
    }

    func onFastestConnectionsTapped() {
        print("Fastest connections row tapped")
    }

    func onSearchTapped() {
        print("On Tap Search Button")
    }
}
