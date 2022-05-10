//
//  NimbleSurveyClientType.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 08/05/2022.
//

import RxSwift

protocol NimbleSurveyClientType {
    func login(email: String, password: String) -> Completable
    func surveyList(pageNumber: Int, pageSize: Int) -> Single<[Survey]>
}
