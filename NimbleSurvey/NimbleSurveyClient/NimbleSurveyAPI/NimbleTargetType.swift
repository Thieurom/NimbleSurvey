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
    case surveyList(pageNumber: Int, pageSize: Int)

    var baseURL: URL {
        // TODO: Move to config
        URL(string: "https://survey-api.nimblehq.co/api/v1")!
    }

    var path: String {
        switch self {
        case .login:
            return "/oauth/token"
        case .surveyList:
            return "/surveys"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .login:
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

        case let .surveyList(pageNumber, pageSize):
            return [
                "page_number": pageNumber,
                "page_size": pageSize
            ]
        }
    }

    var encoding: ParameterEncoding {
        switch self {
        case .login:
            return JSONEncoding()
        case .surveyList:
            return URLEncoding()
        }
    }

    var authorizationType: AuthorizationType? {
        switch self {
        case .login:
            return nil
        case .surveyList:
            return .bearer
        }
    }
}
