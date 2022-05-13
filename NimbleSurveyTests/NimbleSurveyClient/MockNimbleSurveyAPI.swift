//
//  MockNimbleSurveyAPI.swift
//  NimbleSurveyTests
//
//  Created by Doan Le Thieu on 09/05/2022.
//

import Foundation
@testable import NimbleSurvey
import RxSwift

class MockNimbleSurveyAPI: NimbleSurveyAPIProtocol {
    var loginResult: Result<Credential, NimbleSurveyError>?
    var refreshTokenResult: Result<Credential, NimbleSurveyError>?
    var surveyListResult: Result<[Survey], NimbleSurveyError>?

    func login(email: String, password: String, clientId: String, clientSecret: String) -> Single<Credential> {
        switch loginResult {
        case .success(let credential):
            return .just(credential)
        case .failure(let error):
            return .error(error)
        case .none:
            return .error(NimbleSurveyError.authenticationFailed)
        }
    }

    func refreshToken(refreshToken: String, clientId: String, clientSecret: String) -> Single<Credential> {
        switch refreshTokenResult {
        case .success(let credential):
            return .just(credential)
        case .failure(let error):
            return .error(error)
        case .none:
            return .error(NimbleSurveyError.authenticationFailed)
        }
    }

    func surveyList(pageNumber: Int, pageSize: Int) -> Single<[Survey]> {
        switch surveyListResult {
        case .success(let list):
            return .just(list)
        case .failure(let error):
            return .error(error)
        case .none:
            return .just([])
        }
    }
}
