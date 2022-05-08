//
//  AuthenticationAPI.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 09/05/2022.
//

import Alamofire
import Foundation
import RxSwift

class AuthenticationAPI: BaseNetworkAPI<AuthenticationTargetType>, AuthenticationAPIProtocol {
    func login(email: String, password: String, clientId: String, clientSecret: String) -> Completable {
        return request(
            for: .login(
                email: email,
                password: password,
                clientId: clientId,
                clientSecret: clientSecret
            ),
            type: LoginResponse.self
        )
        .asCompletable()
    }
}

// MARK: - API's responses

private struct LoginResponse: Decodable {
    struct Data: Decodable {
        let attributes: Attributes
    }

    struct Attributes: Decodable {
        let accessToken: String
        let tokenType: String
        let expiresIn: Int
        let refreshToken: String
        let createdAt: Double
    }

    let data: Data
}
