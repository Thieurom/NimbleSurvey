//
//  SurveyDetailViewModel.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 14/05/2022.
//

import RxCocoa
import RxSwift

class SurveyDetailViewModel: ViewModelType {

    // MARK: - Nested types

    struct Input {}

    struct Output {
        let startButtonTitle: Driver<String>
    }

    // MARK: - Dependencies

    private let nimbleSurveyClient: NimbleSurveyClientType

    // MARK: - Initialization

    init(nimbleSurveyClient: NimbleSurveyClientType) {
        self.nimbleSurveyClient = nimbleSurveyClient
    }

    func transform(input: Input) -> Output {
        return Output(startButtonTitle: .just(R.string.localizable.survey_start_survey()))
    }
}
