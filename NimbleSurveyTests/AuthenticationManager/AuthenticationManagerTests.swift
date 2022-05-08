//
//  AuthenticationManagerTests.swift
//  NimbleSurveyTests
//
//  Created by Doan Le Thieu on 09/05/2022.
//

import Alamofire
@testable import NimbleSurvey
import RxBlocking
import RxSwift
import XCTest

class AuthenticationManagerTests: XCTestCase {
    // SUT
    private var authenticationManager: AuthenticationManager!

    // Mock dependencies
    private var mockAuthenticationAPI: MockAuthenticationAPI!

    private let email = "john@appleseed.com"
    private let password = "123456"
    private let clientId = "ID"
    private let clientSecret = "SECRET"

    override func tearDown() {
        authenticationManager = nil
        mockAuthenticationAPI = nil

        super.tearDown()
    }

    func testLoginFail() {
        mockAuthenticationAPI = MockAuthenticationAPI(loginResult: .failure(.invalid))

        authenticationManager = AuthenticationManager(
            clientId: clientId,
            clientSecret: clientSecret,
            authenticationAPI: mockAuthenticationAPI
        )

        let result = authenticationManager.login(email: email, password: password)
            .toBlocking()
            .materialize()

        switch result {
        case .completed:
            XCTFail("Should login fail")
        case let .failed(_, error):
            XCTAssertTrue((error as? NimbleSurvey.AuthenticationError) == .invalid)
        }
    }

    func testLoginSuccess() {
        mockAuthenticationAPI = MockAuthenticationAPI(loginResult: .success(true))

        authenticationManager = AuthenticationManager(
            clientId: clientId,
            clientSecret: clientSecret,
            authenticationAPI: mockAuthenticationAPI
        )

        let result = authenticationManager.login(email: email, password: password)
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
