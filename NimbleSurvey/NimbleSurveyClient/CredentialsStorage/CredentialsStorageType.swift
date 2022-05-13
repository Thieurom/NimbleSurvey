//
//  CredentialsStorageType.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 14/05/2022.
//

import KeychainAccess

protocol CredentialsStorageType {
    func store(credentials: Credentials, withKey key: String) -> Bool
    func retrieveCredentials(fromKey key: String) -> Credentials?
    func clearCredentials(ofKey key: String) -> Bool
}

extension Keychain: CredentialsStorageType {
    func store(credentials: Credentials, withKey key: String) -> Bool {
        guard let data = try? JSONEncoder().encode(credentials) else {
            return false
        }

        return (try? set(data, key: key)) != nil
    }

    func retrieveCredentials(fromKey key: String) -> Credentials? {
        guard let data = try? getData(key) else {
            return nil
        }

        return try? JSONDecoder().decode(Credentials.self, from: data)
    }

    func clearCredentials(ofKey key: String) -> Bool {
        return (try? remove(key)) != nil
    }
}
