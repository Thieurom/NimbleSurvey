//
//  AuthenticationTargetType.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 09/05/2022.
//

import Alamofire
import Foundation

enum AuthenticationTargetType: TargetType {
    case login(email: String, password: String, clientId: String, clientSecret: String)

    var path: String {
        switch self {
        case .login:
            return "/oauth/token"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login:
            return .post
        }
    }

    var parameters: Parameters? {
        switch self {
        case let .login(email, password, clientId, clientSecret):
            return [
                "grant_type": "password",
                "email": email,
                "password": password,
                "client_id": clientId,
                "client_secret": clientSecret
            ]
        }
    }

    var encoding: ParameterEncoding {
        JSONEncoding()
    }
}
