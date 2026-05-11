//
//  BahnNavigatorApp.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 8/5/26.
//

import SwiftUI
import SwiftData

@main
struct BahnNavigatorApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: [CachedLocationEntity.self, SavedJourneyEntity.self])
    }
}
