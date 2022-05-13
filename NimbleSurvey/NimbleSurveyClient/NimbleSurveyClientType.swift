//
//  NimbleSurveyClientType.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 08/05/2022.
//

import RxSwift

protocol NimbleSurveyClientType {
    func authenticate(email: String, password: String) -> Completable
    func surveyList(pageNumber: Int, pageSize: Int) -> Single<[Survey]>
    func hasCredentials() -> Bool
}
