//
//  AppColors.swift
//  BahnNavigator
//
//  Created by Shimanto A. on 11/5/26.
//

import SwiftUI
import UIKit

extension Color {
    /// Primary dark background used for the tab bar, buttons, and badges.
    static let appDark = Color(red: 0.15, green: 0.16, blue: 0.18)
    /// Deutsche Bahn brand red used for accents.
    static let appRed = Color(red: 0.87, green: 0.09, blue: 0.17)
}

extension UIColor {
    /// UIKit-side companion to `Color.appDark` for `UIAppearance` configuration.
    static let appDark = UIColor(red: 0.15, green: 0.16, blue: 0.18, alpha: 1)
}
