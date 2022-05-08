//
//  MockAuthenticationAPI.swift
//  NimbleSurveyTests
//
//  Created by Doan Le Thieu on 09/05/2022.
//

import Foundation
@testable import NimbleSurvey
import RxSwift

class MockAuthenticationAPI: AuthenticationAPIProtocol {
    let loginResult: Result<Bool, AuthenticationError>

    init(loginResult: Result<Bool, AuthenticationError>) {
        self.loginResult = loginResult
    }

    func login(email: String, password: String, clientId: String, clientSecret: String) -> Completable {
        switch loginResult {
        case .success:
            return .empty()
        case .failure(let error):
            return .error(error)
        }
    }
}
