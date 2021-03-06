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
    var loginResult: Result<Credentials, APIError>?
    var refreshTokenResult: Result<Credentials, APIError>?
    var surveyListResult: Result<[Survey], APIError>?

    func login(email: String, password: String, clientId: String, clientSecret: String) -> Single<Credentials> {
        switch loginResult {
        case .success(let credentials):
            return .just(credentials)
        case .failure(let error):
            return .error(error)
        case .none:
            return .error(APIError.unknown)
        }
    }

    func refreshToken(refreshToken: String, clientId: String, clientSecret: String) -> Single<Credentials> {
        switch refreshTokenResult {
        case .success(let credentials):
            return .just(credentials)
        case .failure(let error):
            return .error(error)
        case .none:
            return .error(APIError.unknown)
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
