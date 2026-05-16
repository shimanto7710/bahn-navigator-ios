//
//  HomeView.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 8/5/26.
//

import SwiftUI
import UIKit

private enum HomeTab: Hashable {
    case booking
    case nearby
    case journeys
    case profile
}

@MainActor
struct HomeView: View {
    @State private var selectedTab: HomeTab = .booking

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .appDark
        appearance.stackedLayoutAppearance.selected.iconColor = .white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.stackedLayoutAppearance.normal.iconColor = .systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                SearchJourneyView()
            }
            .tabItem {
                Image(systemName: "arrow.triangle.swap")
                Text("Booking")
            }
            .tag(HomeTab.booking)

            NearbyView()
                .tabItem {
                    Image(systemName: "location")
                    Text("Nearby")
                }
                .tag(HomeTab.nearby)

            SavedJourneysView()
                .tabItem {
                    Image(systemName: "list.bullet.rectangle")
                    Text("Journeys")
                }
                .tag(HomeTab.journeys)

            ProfileView()
                .tabItem {
                    Image(systemName: "person.crop.square")
                    Text("Profile")
                }
                .tag(HomeTab.profile)
        }
        .tint(.white)
        .toolbarBackground(Color.appDark, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

#Preview("iPhone 16 Pro") {
    HomeView()
}
