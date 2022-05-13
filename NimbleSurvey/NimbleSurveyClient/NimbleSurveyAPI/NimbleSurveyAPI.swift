//
//  NimbleSurveyAPI.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 09/05/2022.
//

import Alamofire
import Foundation
import RxSwift

class NimbleSurveyAPI: BaseNetworkAPI<NimbleTargetType>, NimbleSurveyAPIProtocol {
    func login(email: String, password: String, clientId: String, clientSecret: String) -> Single<Credentials> {
        return request(
            for: .login(
                email: email,
                password: password,
                clientId: clientId,
                clientSecret: clientSecret
            ),
            type: OAuthResponse.self
        )
        .map { $0.toCredentials() }
    }

    func refreshToken(refreshToken: String, clientId: String, clientSecret: String) -> Single<Credentials> {
        return request(
            for: .refreshToken(
                refreshToken: refreshToken,
                clientId: clientId,
                clientSecret: clientSecret
            ),
            type: OAuthResponse.self
        )
        .map { $0.toCredentials() }
    }

    func surveyList(pageNumber: Int, pageSize: Int) -> Single<[Survey]> {
        request(
            for: .surveyList(
                pageNumber: pageNumber,
                pageSize: pageSize
            ),
            type: SurveysResponse.self
        )
        .map { $0.toSurveys() }
    }
}

// MARK: - API's responses (naming convetion: suffix with `Response`)

private struct OAuthResponse: Decodable {
    struct Data: Decodable {
        let attributes: Attributes
    }

    struct Attributes: Decodable {
        let accessToken: String
        let tokenType: String
        let expiresIn: Double
        let refreshToken: String
        let createdAt: Double
    }

    let data: Data

    // Map to app's object
    func toCredentials() -> Credentials {
        let attributes = data.attributes

        return Credentials(
            accessToken: attributes.accessToken,
            tokenType: attributes.tokenType,
            refreshToken: attributes.refreshToken,
            validUntil: Date(timeIntervalSince1970: attributes.createdAt + attributes.expiresIn)
        )
    }
}

private struct SurveysResponse: Decodable {
    struct Datum: Decodable {
        let id: String
        let attributes: Attributes
    }

    struct Attributes: Decodable {
        let title: String
        let description: String
        let coverImageUrl: URL?
    }

    let data: [Datum]

    // Map to app's object
    func toSurveys() -> [Survey] {
        return data.map { datum in
            let attributes = datum.attributes

            return Survey(
                id: datum.id,
                title: attributes.title,
                description: attributes.description,
                coverImageUrl: attributes.coverImageUrl
            )
        }
    }
}
