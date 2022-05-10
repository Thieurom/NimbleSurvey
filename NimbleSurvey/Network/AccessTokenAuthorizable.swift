//
//  AccessTokenAuthorizable.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 12/05/2022.
//

enum AuthorizationType: String {
    case bearer = "Bearer"
}

protocol AccessTokenAuthorizable {
    var authorizationType: AuthorizationType? { get }
}
