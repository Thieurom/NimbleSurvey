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

    func login(email: String, password: String, clientId: String, clientSecret: String) -> Completable {
        return request(
            for: .login(
                email: email,
                password: password,
                clientId: clientId,
                clientSecret: clientSecret
            ),
            type: LoginResponse.self
        )
        .asCompletable()
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

private struct LoginResponse: Decodable {
    struct Data: Decodable {
        let attributes: Attributes
    }

    struct Attributes: Decodable {
        let accessToken: String
        let tokenType: String
        let expiresIn: Int
        let refreshToken: String
        let createdAt: Double
    }

    let data: Data
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
