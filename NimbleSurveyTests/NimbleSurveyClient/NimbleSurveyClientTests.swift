//
//  NimbleSurveyClientTests.swift
//  NimbleSurveyTests
//
//  Created by Doan Le Thieu on 09/05/2022.
//

import Alamofire
@testable import NimbleSurvey
import RxBlocking
import RxSwift
import XCTest

class NimbleSurveyClientTests: XCTestCase {
    // SUT
    private var nimbleSurveyClient: NimbleSurveyClient!

    // Mock dependencies
    private var mockNimbleSurveyAPI: MockNimbleSurveyAPI!

    private let email = "john@appleseed.com"
    private let password = "123456"
    private let clientId = "ID"
    private let clientSecret = "SECRET"

    override func setUp() {
        super.setUp()

        nimbleSurveyClient = NimbleSurveyClient(
            clientId: clientId,
            clientSecret: clientSecret
        )

        mockNimbleSurveyAPI = MockNimbleSurveyAPI()
    }

    override func tearDown() {
        nimbleSurveyClient = nil
        mockNimbleSurveyAPI = nil

        super.tearDown()
    }

    // MARK: - Test authenticate

    func testAuthenticateFail() {
        mockNimbleSurveyAPI.loginResult = .failure(.authenticationFailed)
        nimbleSurveyClient.nimbleSurveyAPI = mockNimbleSurveyAPI

        let result = nimbleSurveyClient.authenticate(email: email, password: password)
            .toBlocking()
            .materialize()

        switch result {
        case .completed:
            XCTFail("Should authenticate fail")
        case let .failed(_, error):
            XCTAssertTrue((error as? NimbleSurvey.NimbleSurveyError) == .authenticationFailed)
        }
    }

    func testAuthenticateSuccess() {
        mockNimbleSurveyAPI.loginResult = .success(
            Credential(
                accessToken: "at1234",
                tokenType: "Bearer",
                refreshToken: "rt5678",
                validUntil: Date()
            )
        )
        
        nimbleSurveyClient.nimbleSurveyAPI = mockNimbleSurveyAPI

        let result = nimbleSurveyClient.authenticate(email: email, password: password)
            .toBlocking()
            .materialize()

        switch result {
        case .completed:
            break
        case .failed:
            XCTFail("Should authenticate successfully")
        }
    }

    // MARK: - Test Survey list

    func testGetSurveyListFail() {
        mockNimbleSurveyAPI.surveyListResult = .failure(.failedToGetSurveys)
        nimbleSurveyClient.nimbleSurveyAPI = mockNimbleSurveyAPI

        let result = nimbleSurveyClient.surveyList(pageNumber: 1, pageSize: 10)
            .toBlocking()
            .materialize()

        switch result {
        case .completed:
            XCTFail("Should get survey list failed")
        case .failed:
            break
        }
    }

    func testGetSurveyListWithOneItem() throws {
        let surveys = [
            Survey(
                id: "123",
                title: "Lorem",
                description: "Lorem ipsum",
                coverImageUrl: nil
            )
        ]

        mockNimbleSurveyAPI.surveyListResult = .success(surveys)
        nimbleSurveyClient.nimbleSurveyAPI = mockNimbleSurveyAPI

        let result = try nimbleSurveyClient.surveyList(pageNumber: 1, pageSize: 10)
            .toBlocking()
            .first()

        XCTAssertEqual(result, surveys)
    }

    func testGetSurveyListWithTwoItem() throws {
        let surveys = [
            Survey(
                id: "123",
                title: "Lorem",
                description: "Lorem",
                coverImageUrl: nil
            ),
            Survey(
                id: "456",
                title: "ipsum",
                description: "ipsum",
                coverImageUrl: URL(string: "http://any.com")
            )
        ]

        mockNimbleSurveyAPI.surveyListResult = .success(surveys)
        nimbleSurveyClient.nimbleSurveyAPI = mockNimbleSurveyAPI

        let result = try nimbleSurveyClient.surveyList(pageNumber: 1, pageSize: 10)
            .toBlocking()
            .first()

        XCTAssertEqual(result, surveys)
    }
}
