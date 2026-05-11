//
//  SavedJourneyEntity.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 11/5/26.
//

import Foundation
import SwiftData

@Model
final class SavedJourneyEntity {
    @Attribute(.unique) var id: String
    var fromName: String
    var toName: String
    var departureDate: Date
    var savedAt: Date

    init(
        id: String,
        fromName: String,
        toName: String,
        departureDate: Date,
        savedAt: Date = Date()
    ) {
        self.id = id
        self.fromName = fromName
        self.toName = toName
        self.departureDate = departureDate
        self.savedAt = savedAt
    }
}
