//
//  AuthenticationProtocol.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 08/05/2022.
//

import RxSwift

protocol AuthenticationProtocol {
    func login(email: String, password: String) -> Completable
}
