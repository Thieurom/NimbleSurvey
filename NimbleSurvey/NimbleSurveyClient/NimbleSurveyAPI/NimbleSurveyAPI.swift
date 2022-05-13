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

    // We explicitly require none nil `AccessTokenProviding`
    init(session: Session = .default, accessTokenProviding: @escaping AccessTokenProviding) {
        super.init(session: session, accessTokenProviding: accessTokenProviding)
    }

    func login(email: String, password: String, clientId: String, clientSecret: String) -> Single<Credential> {
        return request(
            for: .login(
                email: email,
                password: password,
                clientId: clientId,
                clientSecret: clientSecret
            ),
            type: OAuthResponse.self
        )
        .map { $0.toCredential() }
    }

    func refreshToken(refreshToken: String, clientId: String, clientSecret: String) -> Single<Credential> {
        return request(
            for: .refreshToken(
                refreshToken: refreshToken,
                clientId: clientId,
                clientSecret: clientSecret
            ),
            type: OAuthResponse.self
        )
        .map { $0.toCredential() }
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

// MARK: - API's responses

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
    func toCredential() -> Credential {
        let attributes = data.attributes

        return Credential(
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
