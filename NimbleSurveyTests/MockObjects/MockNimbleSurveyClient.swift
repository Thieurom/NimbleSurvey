//
//  MockNimbleSurveyClient.swift
//  NimbleSurveyTests
//
//  Created by Doan Le Thieu on 12/05/2022.
//

@testable import NimbleSurvey
import RxSwift

class MockNimbleSurveyClient: NimbleSurveyClientType {
    var authenticateResult: Result<Bool, NimbleSurveyError>?
    var hasCredentialsResult = true
    var surveyListResult: Result<[Survey], NimbleSurveyError>?

    func authenticate(email: String, password: String) -> Completable {
        switch authenticateResult {
        case .success, .none:
            return .empty()
        case .failure(let error):
            return .error(error)
        }
    }

    func hasCredentials() -> Bool {
        return hasCredentialsResult
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
