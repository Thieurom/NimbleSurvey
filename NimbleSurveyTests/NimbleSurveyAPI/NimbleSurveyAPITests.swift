//
//  NimbleSurveyAPITests.swift
//  NimbleSurveyTests
//
//  Created by Doan Le Thieu on 09/05/2022.
//

import Alamofire
@testable import NimbleSurvey
import RxBlocking
import RxSwift
import XCTest

class NimbleSurveyAPITests: XCTestCase {
    // SUT
    private var nimbleSurveyAPI: NimbleSurveyAPI!

    private var configuration: URLSessionConfiguration!

    private let email = "john@appleseed.com"
    private let password = "123456"
    private let clientId = "ID"
    private let clientSecret = "SECRET"

    override func setUp() {
        super.setUp()

        configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]

        let session = Session(configuration: configuration)

        nimbleSurveyAPI = NimbleSurveyAPI(
            session: session,
            accessTokenProviding: { _ in "FAKE_ACCESS_TOKEN" }
        )
    }

    override func tearDown() {
        nimbleSurveyAPI = nil
        configuration = nil
        MockURLProtocol.responseType = nil

        super.tearDown()
    }

    // MARK: - Test login

    func testLoginFailWithEmptyData() {
        let response = HTTPURLResponse.ok
        let data = Data()
        MockURLProtocol.responseType = .data(response, data)

        let result = nimbleSurveyAPI.login(
            email: email,
            password: password,
            clientId: clientId,
            clientSecret: clientSecret
        )
            .toBlocking()
            .materialize()

        switch result {
        case .completed:
            XCTFail("Should login failed")
        case let .failed(_, error: error):
            XCTAssertTrue((error as? APIError) == .unknown)
        }
    }

    func testLoginFailWith4xxError() {
        let response = HTTPURLResponse.clientFail

        let json = """
        {
            "errors": [{
                "code": "invalid"
            }]
        }
        """

        let data = json.data(using: .utf8)!
        MockURLProtocol.responseType = .data(response, data)

        let result = nimbleSurveyAPI.login(
            email: email,
            password: password,
            clientId: clientId,
            clientSecret: clientSecret
        )
            .toBlocking()
            .materialize()

        switch result {
        case .completed:
            XCTFail("Should login failed")
        case let .failed(_, error: error):
            XCTAssertTrue((error as? APIError) == .network)
        }
    }

    func testLoginFailWithWrongFormatData() {
        let response = HTTPURLResponse.ok

        // `accessing_token` instead of `access_token`
        let json = """
        {
            "data": {
                "id": "10",
                "type": "token",
                "attributes": {
                    "accessing_token": "ACCESS_TOKEN",
                    "token_type": "Bearer",
                    "expires_in": 7200,
                    "refresh_token": "REFRESH_TOKEN",
                    "created_at": 1597169495
                }
            }
        }
        """

        let data = json.data(using: .utf8)!
        MockURLProtocol.responseType = .data(response, data)

        let result = nimbleSurveyAPI.login(
            email: email,
            password: password,
            clientId: clientId,
            clientSecret: clientSecret
        )
            .toBlocking()
            .materialize()

        switch result {
        case .completed:
            XCTFail("Should login failed")
        case let .failed(_, error: error):
            XCTAssertTrue((error as? APIError) == .parsing)
        }
    }

    func testLoginFailWithUnknownError() {
        let error = NSError(domain: "Login", code: 101)
        MockURLProtocol.responseType = .error(error)
        let result = nimbleSurveyAPI.login(
            email: email,
            password: password,
            clientId: clientId,
            clientSecret: clientSecret
        )
            .toBlocking()
            .materialize()

        switch result {
        case .completed:
            XCTFail("Should login failed")
        case let .failed(_, error: error):
            XCTAssertTrue((error as? APIError) == .unknown)
        }
    }

    func testLoginSuccess() {
        let response = HTTPURLResponse.ok

        let json = """
        {
            "data": {
                "id": "10",
                "type": "token",
                "attributes": {
                    "access_token": "ACCESS_TOKEN",
                    "token_type": "Bearer",
                    "expires_in": 7200,
                    "refresh_token": "REFRESH_TOKEN",
                    "created_at": 1597169495
                }
            }
        }
        """

        let data = json.data(using: .utf8)!
        MockURLProtocol.responseType = .data(response, data)

        let result = nimbleSurveyAPI.login(
            email: email,
            password: password,
            clientId: clientId,
            clientSecret: clientSecret
        )
            .toBlocking()
            .materialize()

        switch result {
        case .completed:
            break
        case .failed:
            XCTFail("Should login successfully")
        }
    }

    // MARK: - Test survey list

    func testGetSurveyListFailWithEmptyData() {
        let response = HTTPURLResponse.ok
        let data = Data()
        MockURLProtocol.responseType = .data(response, data)

        let result = nimbleSurveyAPI.surveyList(pageNumber: 1, pageSize: 10)
            .toBlocking()
            .materialize()

        switch result {
        case .completed:
            XCTFail("Should get survey list failed")
        case let .failed(_, error: error):
            XCTAssertTrue((error as? APIError) == .unknown)
        }
    }

    func testGetSurveyListFailWith4xxError() {
        let response = HTTPURLResponse.clientFail

        let json = """
        {
            "errors": [{
                "code": "invalid"
            }]
        }
        """

        let data = json.data(using: .utf8)!
        MockURLProtocol.responseType = .data(response, data)

        let result = nimbleSurveyAPI.surveyList(pageNumber: 1, pageSize: 10)
            .toBlocking()
            .materialize()

        switch result {
        case .completed:
            XCTFail("Should get survey list failed")
        case let .failed(_, error: error):
            XCTAssertTrue((error as? APIError) == .network)
        }
    }

    func testGetSurveyListFailWithWrongFormatData() {
        let response = HTTPURLResponse.ok

        // `detail` instead of `description`
        let json = """
        {
            "data": [
                {
                    "id": "d5de6a8f8f5f1cfe51bc",
                    "type": "survey",
                    "attributes": {
                        "title": "Scarlett Bangkok",
                        "detail": "We'd love ot hear from you!",
                        "thank_email_above_threshold": "<span></span>",
                        "thank_email_below_threshold": "<span></span>",
                        "is_active": true,
                        "cover_image_url": "https://dhdbhh0jsld0o.cloudfront.net/m/1ea51560991bcb7d00d0_",
                        "created_at": "2017-01-23T07:48:12.991Z",
                        "active_at": "2015-10-08T07:04:00.000Z",
                        "inactive_at": null,
                        "survey_type": "Restaurant"
                    }
                }
             ]
        }
        """

        let data = json.data(using: .utf8)!
        MockURLProtocol.responseType = .data(response, data)

        let result = nimbleSurveyAPI.surveyList(pageNumber: 1, pageSize: 10)
            .toBlocking()
            .materialize()

        switch result {
        case .completed:
            XCTFail("Should get survey list failed")
        case let .failed(_, error: error):
            XCTAssertTrue((error as? APIError) == .parsing)
        }
    }

    func testGetSurveyListFailWithUnknownError() {
        let error = NSError(domain: "Login", code: 101)
        MockURLProtocol.responseType = .error(error)

        let result = nimbleSurveyAPI.surveyList(pageNumber: 1, pageSize: 10)
            .toBlocking()
            .materialize()

        switch result {
        case .completed:
            XCTFail("Should get survey list failed")
        case let .failed(_, error: error):
            XCTAssertTrue((error as? APIError) == .unknown)
        }
    }

    func testGetSurveyListSuccess() throws {
        let response = HTTPURLResponse.ok

        let json = """
        {
            "data": [
                {
                    "id": "d5de6a8f8f5f1cfe51bc",
                    "type": "survey",
                    "attributes": {
                        "title": "Scarlett Bangkok",
                        "description": "We'd love ot hear from you!",
                        "thank_email_above_threshold": "<span></span>",
                        "thank_email_below_threshold": "<span></span>",
                        "is_active": true,
                        "cover_image_url": "https://dhdbhh0jsld0o.cloudfront.net/m/1ea51560991bcb7d00d0_",
                        "created_at": "2017-01-23T07:48:12.991Z",
                        "active_at": "2015-10-08T07:04:00.000Z",
                        "inactive_at": null,
                        "survey_type": "Restaurant"
                    }
                }
             ]
        }
        """

        let data = json.data(using: .utf8)!
        MockURLProtocol.responseType = .data(response, data)

        let result = try nimbleSurveyAPI.surveyList(pageNumber: 1, pageSize: 10)
            .toBlocking()
            .first()

        let expectedResult = [
            Survey(
                id: "d5de6a8f8f5f1cfe51bc",
                title: "Scarlett Bangkok",
                description: "We'd love ot hear from you!",
                coverImageUrl: URL(string: "https://dhdbhh0jsld0o.cloudfront.net/m/1ea51560991bcb7d00d0_")
            )
        ]

        XCTAssertEqual(result, expectedResult)
    }
}

private extension HTTPURLResponse {
    // swiftlint:disable:next identifier_name
    static let ok = HTTPURLResponse(
        url: URL(string: "http://any.com")!,
        statusCode: 201,
        httpVersion: nil,
        headerFields: nil
    )!

    static let clientFail = HTTPURLResponse(
        url: URL(string: "http://any.com")!,
        statusCode: 403,
        httpVersion: nil,
        headerFields: nil
    )!
}
