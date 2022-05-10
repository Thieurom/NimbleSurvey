//
//  NimbleSurveyClient.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 08/05/2022.
//

import Alamofire
import Foundation
import RxAlamofire
import RxSwift

enum NimbleSurveyError: Error {
    case authenticationFailed
    case failedToGetSurveys
}

/// A simple client that interacts with Nimble Survey Web (https://github.com/nimblehq/nimble-survey-web)
class NimbleSurveyClient: NimbleSurveyClientType {
    private let clientId: String
    private let clientSecret: String

    // Inject through property
    lazy var nimbleSurveyAPI: NimbleSurveyAPIProtocol = {
        return NimbleSurveyAPI { _ in
            // TODO: Managed by something like CredentialManagers!
            return "ACCESS_TOKEN"
        }
    }()

    init(clientId: String, clientSecret: String) {
        self.clientId = clientId
        self.clientSecret = clientSecret
    }

    func login(email: String, password: String) -> Completable {
        return nimbleSurveyAPI.login(
            email: email,
            password: password,
            clientId: clientId,
            clientSecret: clientSecret
        )
        .catch { _ in
            throw NimbleSurveyError.authenticationFailed
        }
    }

    func surveyList(pageNumber: Int, pageSize: Int) -> Single<[Survey]> {
        return nimbleSurveyAPI.surveyList(pageNumber: pageNumber, pageSize: pageSize)
            .catch { _ in
                throw NimbleSurveyError.failedToGetSurveys
            }
    }
}
