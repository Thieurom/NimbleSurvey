//
//  AuthenticationAPITests.swift
//  NimbleSurveyTests
//
//  Created by Doan Le Thieu on 09/05/2022.
//

import Alamofire
@testable import NimbleSurvey
import RxBlocking
import RxSwift
import XCTest

class AuthenticationAPITests: XCTestCase {
    // SUT
    private var authenticationAPI: AuthenticationAPI!

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
        authenticationAPI = AuthenticationAPI(session: session)
    }

    override func tearDown() {
        authenticationAPI = nil
        configuration = nil
        MockURLProtocol.responseType = nil

        super.tearDown()
    }

    func testLoginFailWithEmptyData() {
        let response = HTTPURLResponse(
            url: URL(string: "http://any.com")!,
            statusCode: 200,
            httpVersion: nil,
            headerFields: nil
        )!

        let data = Data()

        MockURLProtocol.responseType = .data(response, data)

        let result = authenticationAPI.login(
            email: email,
            password: password,
            clientId: clientId,
            clientSecret: clientSecret
        )
            .toBlocking()
            .materialize()

        switch result {
        case .completed:
            XCTFail("Should login fail")
        case let .failed(_, error: error):
            XCTAssertTrue((error as? APIError) == .unknown)
        }
    }

    func testLoginFailWith4xxError() {
        let response = HTTPURLResponse(
            url: URL(string: "http://any.com")!,
            statusCode: 403,
            httpVersion: nil,
            headerFields: nil
        )!

        let json = """
        {
            "errors": [{
                "code": "invalid"
            }]
        }
        """

        let data = json.data(using: .utf8)!

        MockURLProtocol.responseType = .data(response, data)

        let result = authenticationAPI.login(
            email: email,
            password: password,
            clientId: clientId,
            clientSecret: clientSecret
        )
            .toBlocking()
            .materialize()

        switch result {
        case .completed:
            XCTFail("Should login fail")
        case let .failed(_, error: error):
            XCTAssertTrue((error as? APIError) == .network)
        }
    }

    func testLoginFailWithWrongFormatData() {
        let response = HTTPURLResponse(
            url: URL(string: "http://any.com")!,
            statusCode: 201,
            httpVersion: nil,
            headerFields: nil
        )!

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

        let result = authenticationAPI.login(
            email: email,
            password: password,
            clientId: clientId,
            clientSecret: clientSecret
        )
            .toBlocking()
            .materialize()

        switch result {
        case .completed:
            XCTFail("Should login fail")
        case let .failed(_, error: error):
            XCTAssertTrue((error as? APIError) == .parsing)
        }
    }

    func testLoginFailWithUnknownError() {
        let error = NSError(domain: "Login", code: 101)
        MockURLProtocol.responseType = .error(error)

        let result = authenticationAPI.login(
            email: email,
            password: password,
            clientId: clientId,
            clientSecret: clientSecret
        )
            .toBlocking()
            .materialize()

        switch result {
        case .completed:
            XCTFail("Should login fail")
        case let .failed(_, error: error):
            XCTAssertTrue((error as? APIError) == .unknown)
        }
    }

    func testLoginSuccess() {
        let response = HTTPURLResponse(
            url: URL(string: "http://any.com")!,
            statusCode: 201,
            httpVersion: nil,
            headerFields: nil
        )!

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

        let result = authenticationAPI.login(
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
            XCTFail("Should login success")
        }
    }
}
