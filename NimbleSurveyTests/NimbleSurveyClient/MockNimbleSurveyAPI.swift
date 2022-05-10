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
    var loginResult: Result<Bool, NimbleSurveyError>?
    var surveyListResult: Result<[Survey], NimbleSurveyError>?

    func login(email: String, password: String, clientId: String, clientSecret: String) -> Completable {
        switch loginResult {
        case .success, .none:
            return .empty()
        case .failure(let error):
            return .error(error)
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
