//
//  Theme.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 07/05/2022.
//

import UIKit

// A simple style guides
struct Theme {
    struct Font {
        static let headline = UIFont.systemFont(ofSize: 34, weight: .bold)
        static let caption = UIFont.systemFont(ofSize: 28, weight: .bold)
        static let title = UIFont.systemFont(ofSize: 17, weight: .semibold)
        static let subtitle = UIFont.systemFont(ofSize: 13, weight: .semibold)
        static let body = UIFont.systemFont(ofSize: 17, weight: .regular)
        static let small = UIFont.systemFont(ofSize: 15, weight: .regular)
    }

    struct Color {
        static let primaryText = UIColor.white
        // swiftlint:disable:next object_literal
        static let primaryBackground = UIColor(red: 21 / 255, green: 21 / 255, blue: 26 / 255, alpha: 1)
    }
}
