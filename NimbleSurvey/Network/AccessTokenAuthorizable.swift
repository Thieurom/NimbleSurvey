//
//  AccessTokenAuthorizable.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 12/05/2022.
//

enum AuthorizationType {
    case basic
    case bearer

    var value: String {
        switch self {
        case .basic: return "Basic"
        case .bearer: return "Bearer"
        }
    }
}

protocol AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? { get }
}
