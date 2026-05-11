//
//  CachedLocationEntity.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 11/5/26.
//

import Foundation
import SwiftData

@Model
final class CachedLocationEntity {
    @Attribute(.unique) var id: String
    var name: String
    var type: String
    var latitude: Double?
    var longitude: Double?
    @Attribute(.externalStorage) var rawData: Data?
    var savedAt: Date

    init(
        id: String,
        name: String,
        type: String,
        latitude: Double?,
        longitude: Double?,
        rawData: Data?,
        savedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.type = type
        self.latitude = latitude
        self.longitude = longitude
        self.rawData = rawData
        self.savedAt = savedAt
    }
}
