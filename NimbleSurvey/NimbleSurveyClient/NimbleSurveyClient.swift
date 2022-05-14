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
    case failedToGetSurveys
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
        .catch { _ in
            throw NimbleSurveyError.authenticationFailed
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
        return validCredential()
            .flatMap { [weak self] _ in
                guard let self = self else {
                    return .error(NimbleSurveyError.unAuthorized)
                }

                return self.nimbleSurveyAPI.surveyList(pageNumber: pageNumber, pageSize: pageSize)
            }
            .catch { _ in
                throw NimbleSurveyError.failedToGetSurveys
            }
    }
}

// MARK: - Internal

extension NimbleSurveyClient {
    // Get the valid credentials.
    // If there's no existing one, fail out.
    // Return one if it's still valid, otherwise request a new one.
    // TODO: Make this method thread-safe
    private func validCredential() -> Single<Credentials> {
        guard let credentials = credentialsStorage.retrieveCredentials(fromKey: Self.storageKey) else {
            return .error(NimbleSurveyError.unAuthorized)
        }

        if credentials.validUntil > Date() {
            return .just(credentials)
        }

        return nimbleSurveyAPI.refreshToken(
            refreshToken: credentials.refreshToken,
            clientId: clientId,
            clientSecret: clientSecret
        )
        .do(onSuccess: { [weak self] in
            // Store newly-refresh credentials
            _ = self?.credentialsStorage.store(credentials: $0, withKey: Self.storageKey)
        }, onError: { [weak self] _ in
            // Clear the old credentials in case fail refreshing new one.
            _ = self?.credentialsStorage.clearCredentials(ofKey: Self.storageKey)
        })
    }
}
