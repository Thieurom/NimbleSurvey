//
//  MockCredentialStorage.swift
//  NimbleSurveyTests
//
//  Created by Doan Le Thieu on 14/05/2022.
//

@testable import NimbleSurvey

class MockCredentialStorage: CredentialsStorageType {
    var storeResult = true
    var retrieveResult: Credentials?
    var clearResult = true

    func store(credentials: Credentials, withKey key: String) -> Bool {
        return storeResult
    }

    func retrieveCredentials(fromKey key: String) -> Credentials? {
        return retrieveResult
    }

    func clearCredentials(ofKey key: String) -> Bool {
        return clearResult
    }
}
