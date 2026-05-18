//
//  AppRouter.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 18/5/26.
//

import SwiftUI

// MARK: - Route

/// Every screen the booking tab can navigate to.
/// Add a new case here whenever a new destination is introduced.
enum Route: Hashable {
    case journeyResults(JourneySearchParams)
}

// MARK: - AppRouter

/// Single source of truth for in-app navigation.
/// Inject via .environmentObject(router) and read with @EnvironmentObject var router: AppRouter.
@MainActor
final class AppRouter: ObservableObject {

    /// Drives the booking tab's NavigationStack.
    @Published var bookingPath = NavigationPath()

    func navigate(to route: Route) {
        bookingPath.append(route)
    }

    func goBack() {
        guard !bookingPath.isEmpty else { return }
        bookingPath.removeLast()
    }

    func goToRoot() {
        bookingPath.removeLast(bookingPath.count)
    }
}
