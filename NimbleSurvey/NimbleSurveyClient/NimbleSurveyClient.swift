//
//  NimbleSurveyClient.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 08/05/2022.
//

import Foundation
import RxSwift

enum NimbleSurveyError: Error {
    case unAuthorized
    case authenticationFailed
    case unknown
}

/// A simple client that interacts with Nimble Survey Web (https://github.com/nimblehq/nimble-survey-web)
class NimbleSurveyClient: NimbleSurveyClientType {
    private static let storageKey = "nimble.credentials"
    private let clientId: String
    private let clientSecret: String

    // Dependencies
    // Inject through property
    lazy var nimbleSurveyAPI: NimbleSurveyAPIProtocol = {
        return NimbleSurveyAPI { [weak self] target in
            guard case .surveyList = target else {
                return nil
            }

            return self?.credentialsStorage.retrieveCredentials(fromKey: Self.storageKey)?.accessToken
        }
    }()

    private let credentialsStorage: CredentialsStorageType

    init(clientId: String, clientSecret: String, credentialsStorage: CredentialsStorageType) {
        self.clientId = clientId
        self.clientSecret = clientSecret
        self.credentialsStorage = credentialsStorage
    }

    /// Authenticate with email and password.
    /// - Parameters:
    ///   - email: email
    ///   - password: password
    func authenticate(email: String, password: String) -> Completable {
        return nimbleSurveyAPI.login(
            email: email,
            password: password,
            clientId: clientId,
            clientSecret: clientSecret
        )
        .do(onSuccess: { [weak self] in
            _ = self?.credentialsStorage.store(credentials: $0, withKey: Self.storageKey)
        })
        .asCompletable()
        .catch { error in
            switch error {
            case APIError.unAuthorized:
                throw NimbleSurveyError.unAuthorized
            case APIError.badRequest:
                throw NimbleSurveyError.authenticationFailed
            default:
                throw NimbleSurveyError.unknown
            }
        }
    }

    /// Check if there's an existing credentials.
    /// - Returns: `true` if there's one, `false` otherwise.
    func hasCredentials() -> Bool {
        // Note that we just check if there's an exsisting credentials,
        // we don't test its expire date here.
        return credentialsStorage.retrieveCredentials(fromKey: Self.storageKey) != nil
    }

    /// Get the list of surveys, with given page number and page size.
    /// - Parameters:
    ///   - pageNumber: page number
    ///   - pageSize: page number
    /// - Returns: List of surveys
    func surveyList(pageNumber: Int, pageSize: Int) -> Single<[Survey]> {
        return makeRequest { [weak self] in
            guard let self = self else {
                return .error(NimbleSurveyError.unknown)
            }

            return self.nimbleSurveyAPI.surveyList(
                pageNumber: pageNumber,
                pageSize: pageSize
            )
        }
    }
}

// MARK: - Internal

extension NimbleSurveyClient {
    private func makeRequest<M>(_ request: @escaping () -> Single<M>) -> Single<M> {
        guard let credentials = credentialsStorage.retrieveCredentials(fromKey: Self.storageKey) else {
            return .error(NimbleSurveyError.unAuthorized)
        }

        // When retry, we want to make a new request, because it'll be configed
        // with new access token.
        // If we subscribe the old one like `request.retry`,
        // => continue with obsolete access token => infinite loop.
        // That's why we use Single factory here.
        return Single.deferred {
            return request()
        }
        .retry { [weak self] error -> Observable<Credentials> in
            return error
                .flatMap { [weak self] error -> Observable<Credentials> in
                    guard let self = self else {
                        return .empty()
                    }

                    if case APIError.unAuthorized = error {
                        return self.nimbleSurveyAPI.refreshToken(
                            refreshToken: credentials.refreshToken,
                            clientId: self.clientId,
                            clientSecret: self.clientSecret
                        )
                        .do(onSuccess: { [weak self] in
                            // Store newly-refresh credentials
                            _ = self?.credentialsStorage.store(credentials: $0, withKey: Self.storageKey)
                        }, onError: { [weak self] _ in
                            // Clear the old credentials in case fail refreshing new one.
                            _ = self?.credentialsStorage.clearCredentials(ofKey: Self.storageKey)
                        })
                        .asObservable()
                    }

                    return Observable.error(error)
                }
        }
    }
}
