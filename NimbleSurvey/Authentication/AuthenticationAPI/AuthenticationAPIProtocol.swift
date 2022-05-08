//
//  AuthenticationAPIProtocol.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 09/05/2022.
//

import RxSwift

protocol AuthenticationAPIProtocol {
    func login(email: String, password: String, clientId: String, clientSecret: String) -> Completable
}
