//
//  SurveyDetailViewModelTests.swift
//  NimbleSurveyTests
//
//  Created by Doan Le Thieu on 19/05/2022.
//

import Alamofire
@testable import NimbleSurvey
import RxBlocking
import RxSwift
import XCTest

class SurveyDetailViewModelTests: XCTestCase {
    // SUT
    private var surveyDetailViewModel: SurveyDetailViewModel!

    // Mock dependencies
    private var mockNimbleSurveyClient: MockNimbleSurveyClient!

    override func tearDown() {
        surveyDetailViewModel = nil
        mockNimbleSurveyClient = nil

        super.tearDown()
    }

    func testOutput() throws {
        mockNimbleSurveyClient = MockNimbleSurveyClient()
        surveyDetailViewModel = SurveyDetailViewModel(nimbleSurveyClient: mockNimbleSurveyClient)

        let input = SurveyDetailViewModel.Input()
        let output = surveyDetailViewModel.transform(input: input)

        XCTAssertEqual(try output.startButtonTitle.toBlocking().first()!, (R.string.localizable.survey_start_survey()))
    }
}
