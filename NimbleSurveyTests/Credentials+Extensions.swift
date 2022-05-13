//
//  Credentials+Extensions.swift
//  NimbleSurveyTests
//
//  Created by Doan Le Thieu on 14/05/2022.
//

import Foundation
@testable import NimbleSurvey

extension Credentials {
    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-mm-dd HH:mm:ss"
        return formatter
    }()

    // Overload initializer
    init?(accessToken: String, tokenType: String, refreshToken: String, validUntil: String) {
        guard let expireDate = Credentials.dateFormatter.date(from: validUntil) else {
            return nil
        }

        self = .init(accessToken: accessToken, tokenType: tokenType, refreshToken: refreshToken, validUntil: expireDate)
    }
}
