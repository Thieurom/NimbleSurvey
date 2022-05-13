//
//  Credential.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 13/05/2022.
//

import Foundation

struct Credential: Equatable, Codable {
    let accessToken: String
    let tokenType: String
    let refreshToken: String
    let validUntil: Date
    
    init(accessToken: String, tokenType: String, refreshToken: String, validUntil: Date) {
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.refreshToken = refreshToken
        self.validUntil = validUntil
    }
}
