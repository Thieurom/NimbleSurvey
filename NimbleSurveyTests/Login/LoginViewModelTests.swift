//
//  LoginViewModelTests.swift
//  NimbleSurveyTests
//
//  Created by Doan Le Thieu on 09/05/2022.
//

import Alamofire
@testable import NimbleSurvey
import RxBlocking
import RxSwift
import RxTest
import XCTest

class LoginViewModelTests: XCTestCase {
    // SUT
    private var loginViewModel: LoginViewModel!

    // Mock dependencies
    private var mockNimbleSurveyClient: NimbleSurveyClientType!

    private var scheduler: TestScheduler!
    private var disposeBag: DisposeBag!

    override func setUp() {
        super.setUp()

        scheduler = TestScheduler(initialClock: 0)
        disposeBag = DisposeBag()
    }

    override func tearDown() {
        loginViewModel = nil
        mockNimbleSurveyClient = nil
        scheduler = nil

        super.tearDown()
    }

    func testLoginDisableInitially() throws {
        mockNimbleSurveyClient = MockNimbleSurveyClient()
        loginViewModel = LoginViewModel(nimbleSurveyClient: mockNimbleSurveyClient)

        let email = PublishSubject<String>()
        let password = PublishSubject<String>()
        let loginTrigger = PublishSubject<Void>()

        let input = LoginViewModel.Input(
            email: email.asObservable(),
            password: password.asObservable(),
            loginTrigger: loginTrigger.asObservable()
        )

        let output = loginViewModel.transform(input: input)

        XCTAssertFalse(try output.loginEnabled.toBlocking().first()!)
    }
}
