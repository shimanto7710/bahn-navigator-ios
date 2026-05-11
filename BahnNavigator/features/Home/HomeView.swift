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
    private let tabBarColor = Color(red: 0.15, green: 0.16, blue: 0.18)

    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 0.15, green: 0.16, blue: 0.18, alpha: 1)
        appearance.stackedLayoutAppearance.selected.iconColor = .white
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.stackedLayoutAppearance.normal.iconColor = .systemGray
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.systemGray]

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            SearchJourneyView()
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

            JourneysView()
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
        .toolbarBackground(tabBarColor, for: .tabBar)
        .toolbarBackground(.visible, for: .tabBar)
    }
}

struct NearbyView: View {
    var body: some View {
        Text("Nearby")
    }
}

struct JourneysView: View {
    var body: some View {
        Text("Journeys")
    }
}

struct ProfileView: View {
    var body: some View {
        Text("Profile")
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView()
            .previewDevice("iPhone 16 Pro")
    }
}
