//
//  AppConfiguration.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 11/5/26.
//

import Foundation

enum AppConfiguration {
    /// Switch to your hosted ML API URL before going live.
    /// Example: URL(string: "https://api.bahnnavigator.com")!
    static let baseURL = URL(string: "http://localhost:3000")!
}
