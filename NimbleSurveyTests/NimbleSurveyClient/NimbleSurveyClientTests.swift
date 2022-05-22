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
    private var mockCredentialsStorage: MockCredentialStorage!

    private let email = "john@appleseed.com"
    private let password = "123456"
    private let clientId = "ID"
    private let clientSecret = "SECRET"

    override func setUp() {
        super.setUp()

        mockNimbleSurveyAPI = MockNimbleSurveyAPI()
        mockCredentialsStorage = MockCredentialStorage()

        nimbleSurveyClient = NimbleSurveyClient(
            clientId: clientId,
            clientSecret: clientSecret,
            credentialsStorage: mockCredentialsStorage
        )
    }

    override func tearDown() {
        nimbleSurveyClient = nil
        mockNimbleSurveyAPI = nil
        mockCredentialsStorage = nil

        super.tearDown()
    }

    // MARK: - Test authenticate

    func testAuthenticateFailByWrongClientId() {
        mockNimbleSurveyAPI.loginResult = .failure(.unAuthorized)
        nimbleSurveyClient.nimbleSurveyAPI = mockNimbleSurveyAPI

        let result = nimbleSurveyClient.authenticate(email: email, password: password)
            .toBlocking()
            .materialize()

        switch result {
        case .completed:
            XCTFail("Should authenticate fail")
        case let .failed(_, error):
            XCTAssertTrue((error as? NimbleSurvey.NimbleSurveyError) == .unAuthorized)
        }
    }

    func testAuthenticateFailByWrongUserInfo() {
        mockNimbleSurveyAPI.loginResult = .failure(.badRequest)
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

    func testAuthenticateFailByUnknowError() {
        mockNimbleSurveyAPI.loginResult = .failure(.unknown)
        nimbleSurveyClient.nimbleSurveyAPI = mockNimbleSurveyAPI

        let result = nimbleSurveyClient.authenticate(email: email, password: password)
            .toBlocking()
            .materialize()

        switch result {
        case .completed:
            XCTFail("Should authenticate fail")
        case let .failed(_, error):
            XCTAssertTrue((error as? NimbleSurvey.NimbleSurveyError) == .unknown)
        }
    }

    func testAuthenticateSuccess() {
        mockNimbleSurveyAPI.loginResult = .success(
            Credentials(
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

    func testHasCredentialFalse() {
        XCTAssertFalse(nimbleSurveyClient.hasCredentials())
    }

    func testHasCredentialTrue() {
        mockCredentialsStorage.retrieveResult = Credentials(
            accessToken: "at1234",
            tokenType: "Bearer",
            refreshToken: "rt5678",
            validUntil: "2022-5-14 01:00:00"
        )

        XCTAssertTrue(nimbleSurveyClient.hasCredentials())
    }

    // MARK: - Test Survey list

    func testGetSurveyListFailWhenHavingNoCredentials() {
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

    func testGetSurveyListFailByAPI() {
        guard let credentials = Credentials(
            accessToken: "at1234",
            tokenType: "Bearer",
            refreshToken: "rt5678",
            validUntil: "2022-05-23 00:00:00"
        ) else {
            fatalError("Failed to create credentials")
        }

        mockCredentialsStorage.retrieveResult = credentials
        mockNimbleSurveyAPI.surveyListResult = .failure(.unknown)
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

    func testGetSurveyListFailWhenHavingInvalidCredentialsRefreshFail() {
        guard let credentials = Credentials(
            accessToken: "at1234",
            tokenType: "Bearer",
            refreshToken: "rt5678",
            validUntil: "2022-05-23 00:00:00"
        ) else {
            fatalError("Failed to create credentials")
        }

        mockCredentialsStorage.retrieveResult = credentials
        mockNimbleSurveyAPI.surveyListResult = .failure(.unAuthorized)
        mockNimbleSurveyAPI.refreshTokenResult = .failure(.badRequest)
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

        guard let credentials = Credentials(
            accessToken: "at1234",
            tokenType: "Bearer",
            refreshToken: "rt5678",
            validUntil: "3000-01-01 00:00:00"
        ) else {
            fatalError("Failed to create credentials")
        }

        mockCredentialsStorage.retrieveResult = credentials
        mockNimbleSurveyAPI.refreshTokenResult = .success(credentials)
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

        guard let credentials = Credentials(
            accessToken: "at1234",
            tokenType: "Bearer",
            refreshToken: "rt5678",
            validUntil: "3000-01-01 00:00:00"
        ) else {
            fatalError("Failed to create credentials")
        }

        mockCredentialsStorage.retrieveResult = credentials
        mockNimbleSurveyAPI.refreshTokenResult = .success(credentials)
        mockNimbleSurveyAPI.surveyListResult = .success(surveys)
        nimbleSurveyClient.nimbleSurveyAPI = mockNimbleSurveyAPI

        let result = try nimbleSurveyClient.surveyList(pageNumber: 1, pageSize: 10)
            .toBlocking()
            .first()

        XCTAssertEqual(result, surveys)
    }
}
