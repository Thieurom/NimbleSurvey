//
//  NimbleSurveyAPI.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 09/05/2022.
//

import Alamofire
import Foundation
import JSONAPI
import RxSwift

// MARK: - Private types support parsing API

private typealias Resource<Description: JSONAPI.ResourceObjectDescription> = JSONAPI.ResourceObject<Description, NoMetadata, NoLinks, String>
private typealias SingleDocument<Resource: ResourceObjectType> = JSONAPI.Document<SingleResourceBody<Resource>, NoMetadata, NoLinks, NoIncludes, NoAPIDescription, UnknownJSONAPIError>
private typealias BatchDocument<Resource: ResourceObjectType> = JSONAPI.Document<ManyResourceBody<Resource>, NoMetadata, NoLinks, NoIncludes, NoAPIDescription, UnknownJSONAPIError>

// MARK: -

class NimbleSurveyAPI: BaseNetworkAPI<NimbleTargetType>, NimbleSurveyAPIProtocol {
    func login(email: String, password: String, clientId: String, clientSecret: String) -> Single<Credentials> {
        return request(
            for: .login(
                email: email,
                password: password,
                clientId: clientId,
                clientSecret: clientSecret
            ),
            type: SingleDocument<Resource<TokenResponseDescription>>.self
        )
        .map {
            guard let decoded = $0.body.primaryResource?.value else {
                throw APIError.parsing
            }

            return decoded.toCredentials()
        }
    }

    func refreshToken(refreshToken: String, clientId: String, clientSecret: String) -> Single<Credentials> {
        return request(
            for: .refreshToken(
                refreshToken: refreshToken,
                clientId: clientId,
                clientSecret: clientSecret
            ),
            type: SingleDocument<Resource<TokenResponseDescription>>.self
        )
        .map {
            guard let decoded = $0.body.primaryResource?.value else {
                throw APIError.parsing
            }

            return decoded.toCredentials()
        }
    }

    func surveyList(pageNumber: Int, pageSize: Int) -> Single<[Survey]> {
        request(
            for: .surveyList(
                pageNumber: pageNumber,
                pageSize: pageSize
            ),
            type: BatchDocument<Resource<SurveyResponseDescription>>.self
        )
        .map {
            guard let decoded = $0.body.primaryResource?.values else {
                throw APIError.parsing
            }

            return decoded.map { $0.toSurvey() }
        }
    }
}

// MARK: - API's response description

private struct TokenResponseDescription: ResourceObjectDescription {
    typealias Relationships = NoRelationships
    static let jsonType: String = "token"

    struct Attributes: JSONAPI.Attributes {
        let accessToken: Attribute<String>
        let tokenType: Attribute<String>
        let expiresIn: Attribute<Double>
        let refreshToken: Attribute<String>
        let createdAt: Attribute<Double>
    }
}

private struct SurveyResponseDescription: ResourceObjectDescription {
    typealias Relationships = NoRelationships
    static let jsonType: String = "survey"

    struct Attributes: JSONAPI.Attributes {
        let title: Attribute<String>
        let description: Attribute<String>
        let coverImageUrl: Attribute<URL?>
    }
}

// MARK: - Object's mappers

extension Resource where Description == TokenResponseDescription {
    func toCredentials() -> Credentials {
        return Credentials(
            accessToken: self.accessToken,
            tokenType: self.tokenType,
            refreshToken: self.refreshToken,
            validUntil: Date(timeIntervalSince1970: self.createdAt + self.expiresIn)
        )
    }
}

extension Resource where Description == SurveyResponseDescription {
    func toSurvey() -> Survey {
        return Survey(
            id: self.id.rawValue as? String ?? UUID().uuidString,
            title: self.title,
            description: self.attributes.description.value,
            coverImageUrl: self.coverImageUrl
        )
    }
}
