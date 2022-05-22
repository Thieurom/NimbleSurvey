//
//  NimbleTargetType.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 09/05/2022.
//

import Alamofire
import Foundation

enum NimbleTargetType: TargetType, AccessTokenAuthorizable {
    case login(email: String, password: String, clientId: String, clientSecret: String)
    case refreshToken(refreshToken: String, clientId: String, clientSecret: String)
    case surveyList(pageNumber: Int, pageSize: Int)

    var baseURL: URL {
        // TODO: Move to config
        URL(string: "https://survey-api.nimblehq.co/api/v1")!
    }

    var path: String {
        switch self {
        case .login, .refreshToken:
            return "/oauth/token"
        case .surveyList:
            return "/surveys"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login, .refreshToken:
            return .post
        case .surveyList:
            return .get
        }
    }

    var headers: HTTPHeaders? {
        return nil
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

        case let .refreshToken(refreshToken, clientId, clientSecret):
            return [
                "grant_type": "refresh_token",
                "refresh_token": refreshToken,
                "client_id": clientId,
                "client_secret": clientSecret
            ]

        case let .surveyList(pageNumber, pageSize):
            return [
                "page[number]": pageNumber,
                "page[size]": pageSize
            ]
        }
    }

    var encoding: ParameterEncoding {
        switch self {
        case .login, .refreshToken:
            return JSONEncoding()
        case .surveyList:
            return URLEncoding()
        }
    }

    var authorizationType: AuthorizationType? {
        switch self {
        case .login, .refreshToken:
            return nil
        case .surveyList:
            return .bearer
        }
    }
}
