//
//  NimbleSurveyAPIProtocol.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 09/05/2022.
//

import RxSwift

protocol NimbleSurveyAPIProtocol {
    func login(email: String, password: String, clientId: String, clientSecret: String) -> Single<Credential>
    func refreshToken(refreshToken: String, clientId: String, clientSecret: String) -> Single<Credential>
    func surveyList(pageNumber: Int, pageSize: Int) -> Single<[Survey]>
}
