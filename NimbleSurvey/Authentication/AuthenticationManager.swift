//
//  AuthManager.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 08/05/2022.
//

import Alamofire
import Foundation
import RxAlamofire
import RxSwift

enum AuthenticationError: Error {
    case invalid
}

class AuthenticationManager: AuthenticationProtocol {
    private let clientId: String
    private let clientSecret: String
    private let authenticationAPI: AuthenticationAPIProtocol

    init(clientId: String, clientSecret: String, authenticationAPI: AuthenticationAPIProtocol) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.authenticationAPI = authenticationAPI
    }

    func login(email: String, password: String) -> Completable {
        return authenticationAPI.login(
            email: email,
            password: password,
            clientId: clientId,
            clientSecret: clientSecret
        )
        .catch { _ in
            throw AuthenticationError.invalid
        }
    }
}
