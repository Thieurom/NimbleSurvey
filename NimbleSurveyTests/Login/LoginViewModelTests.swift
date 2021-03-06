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
    private var mockNimbleSurveyClient: MockNimbleSurveyClient!

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

    func testEnableOfLoginWhileUserInputing() {
        mockNimbleSurveyClient = MockNimbleSurveyClient()
        loginViewModel = LoginViewModel(nimbleSurveyClient: mockNimbleSurveyClient)

        let email = scheduler.createColdObservable([
            .next(100, "j"),
            .next(500, "j@"),
            .next(600, "j@n")
        ])

        let password = scheduler.createColdObservable([
            .next(200, "1"),
            .next(300, "12"),
            .next(400, "123")
        ])

        let loginTrigger = PublishSubject<Void>()

        let input = LoginViewModel.Input(
            email: email.asObservable(),
            password: password.asObservable(),
            loginTrigger: loginTrigger.asObservable()
        )

        let output = loginViewModel.transform(input: input)
        let loginEnabled = scheduler.createObserver(Bool.self)

        output.loginEnabled
            .drive(loginEnabled)
            .disposed(by: disposeBag)

        scheduler.start()

        let expected = Recorded.events([
            .next(0, false),
            .next(200, true),
            .next(300, true),
            .next(400, true),
            .next(500, true),
            .next(600, true)
        ])

        XCTAssertEqual(loginEnabled.events, expected)
    }

    func testLoginTriggerFailWhenLoginViewModelDeallocated() {
        mockNimbleSurveyClient = MockNimbleSurveyClient()
        mockNimbleSurveyClient.authenticateResult = .failure(.authenticationFailed)
        loginViewModel = LoginViewModel(nimbleSurveyClient: mockNimbleSurveyClient)

        let email = scheduler.createColdObservable([
            .next(100, "j"),
            .next(200, "j@"),
            .next(300, "j@n")
        ])

        let password = scheduler.createColdObservable([
            .next(400, "1"),
            .next(500, "12"),
            .next(600, "123")
        ])

        let loginTrigger = scheduler.createColdObservable([
            .next(700, ())
        ])

        let input = LoginViewModel.Input(
            email: email.asObservable(),
            password: password.asObservable(),
            loginTrigger: loginTrigger.asObservable()
        )

        let output = loginViewModel.transform(input: input)
        let requestInFlight = scheduler.createObserver(Bool.self)
        let loginResult = scheduler.createObserver(Result<Bool, LoginError>.self)

        output.requestInFlight
            .drive(requestInFlight)
            .disposed(by: disposeBag)

        output.loginResult
            .drive(loginResult)
            .disposed(by: disposeBag)

        // Nil out the `loginViewModel`
        loginViewModel = nil
        scheduler.start()

        let expectedRequestInFlight = Recorded.events([
            .next(0, false)
        ])

        let expectedLoginResult = Recorded.events([
            .next(700, Result<Bool, LoginError>.failure(.unknown))
        ])

        XCTAssertEqual(requestInFlight.events, expectedRequestInFlight)
        XCTAssertEqual(loginResult.events, expectedLoginResult)
    }

    func testLoginTriggerFailByInvalidEmail() {
        mockNimbleSurveyClient = MockNimbleSurveyClient()
        loginViewModel = LoginViewModel(nimbleSurveyClient: mockNimbleSurveyClient)

        let email = scheduler.createColdObservable([
            .next(100, "j"),
            .next(200, "j@"),
            .next(300, "j@n")
        ])

        let password = scheduler.createColdObservable([
            .next(400, "1"),
            .next(500, "12"),
            .next(600, "123")
        ])

        let loginTrigger = scheduler.createColdObservable([
            .next(700, ())
        ])

        let input = LoginViewModel.Input(
            email: email.asObservable(),
            password: password.asObservable(),
            loginTrigger: loginTrigger.asObservable()
        )

        let output = loginViewModel.transform(input: input)
        let requestInFlight = scheduler.createObserver(Bool.self)
        let loginResult = scheduler.createObserver(Result<Bool, LoginError>.self)

        output.requestInFlight
            .drive(requestInFlight)
            .disposed(by: disposeBag)

        output.loginResult
            .drive(loginResult)
            .disposed(by: disposeBag)

        scheduler.start()

        let expectedRequestInFlight = Recorded.events([
            .next(0, false)
        ])

        let expectedLoginResult = Recorded.events([
            .next(700, Result<Bool, LoginError>.failure(.invalidEmail))
        ])

        XCTAssertEqual(requestInFlight.events, expectedRequestInFlight)
        XCTAssertEqual(loginResult.events, expectedLoginResult)
    }

    func testLoginTriggerFailByWrongInput() {
        mockNimbleSurveyClient = MockNimbleSurveyClient()
        mockNimbleSurveyClient.authenticateResult = .failure(.authenticationFailed)
        loginViewModel = LoginViewModel(nimbleSurveyClient: mockNimbleSurveyClient)

        let email = scheduler.createColdObservable([
            .next(100, "j"),
            .next(200, "j@"),
            .next(300, "j@a"),
            .next(400, "j@a."),
            .next(500, "j@a.b")
        ])

        let password = scheduler.createColdObservable([
            .next(600, "1"),
            .next(700, "12"),
            .next(800, "123")
        ])

        let loginTrigger = scheduler.createColdObservable([
            .next(900, ())
        ])

        let input = LoginViewModel.Input(
            email: email.asObservable(),
            password: password.asObservable(),
            loginTrigger: loginTrigger.asObservable()
        )

        let output = loginViewModel.transform(input: input)
        let requestInFlight = scheduler.createObserver(Bool.self)
        let loginResult = scheduler.createObserver(Result<Bool, LoginError>.self)

        output.requestInFlight
            .drive(requestInFlight)
            .disposed(by: disposeBag)

        output.loginResult
            .drive(loginResult)
            .disposed(by: disposeBag)

        scheduler.start()

        let expectedRequestInFlight = Recorded.events([
            .next(0, false),
            .next(900, true),
            .next(900, false)
        ])

        let expectedLoginResult = Recorded.events([
            .next(900, Result<Bool, LoginError>.failure(.authenticationFail))
        ])

        XCTAssertEqual(requestInFlight.events, expectedRequestInFlight)
        XCTAssertEqual(loginResult.events, expectedLoginResult)
    }

    func testLoginTriggerFailByOtherReason() {
        mockNimbleSurveyClient = MockNimbleSurveyClient()
        mockNimbleSurveyClient.authenticateResult = .failure(.unknown)
        loginViewModel = LoginViewModel(nimbleSurveyClient: mockNimbleSurveyClient)

        let email = scheduler.createColdObservable([
            .next(100, "j"),
            .next(200, "j@"),
            .next(300, "j@a"),
            .next(400, "j@a."),
            .next(500, "j@a.b")
        ])

        let password = scheduler.createColdObservable([
            .next(600, "1"),
            .next(700, "12"),
            .next(800, "123")
        ])

        let loginTrigger = scheduler.createColdObservable([
            .next(900, ())
        ])

        let input = LoginViewModel.Input(
            email: email.asObservable(),
            password: password.asObservable(),
            loginTrigger: loginTrigger.asObservable()
        )

        let output = loginViewModel.transform(input: input)
        let requestInFlight = scheduler.createObserver(Bool.self)
        let loginResult = scheduler.createObserver(Result<Bool, LoginError>.self)

        output.requestInFlight
            .drive(requestInFlight)
            .disposed(by: disposeBag)

        output.loginResult
            .drive(loginResult)
            .disposed(by: disposeBag)

        scheduler.start()

        let expectedRequestInFlight = Recorded.events([
            .next(0, false),
            .next(900, true),
            .next(900, false)
        ])

        let expectedLoginResult = Recorded.events([
            .next(900, Result<Bool, LoginError>.failure(.unknown))
        ])

        XCTAssertEqual(requestInFlight.events, expectedRequestInFlight)
        XCTAssertEqual(loginResult.events, expectedLoginResult)
    }

    func testLoginTriggerSucceed() {
        mockNimbleSurveyClient = MockNimbleSurveyClient()
        mockNimbleSurveyClient.authenticateResult = .success(true)
        loginViewModel = LoginViewModel(nimbleSurveyClient: mockNimbleSurveyClient)

        let email = scheduler.createColdObservable([
            .next(100, "j"),
            .next(200, "j@"),
            .next(300, "j@a"),
            .next(400, "j@a."),
            .next(500, "j@a.b")
        ])

        let password = scheduler.createColdObservable([
            .next(600, "1"),
            .next(700, "12"),
            .next(800, "123")
        ])

        let loginTrigger = scheduler.createColdObservable([
            .next(900, ())
        ])

        let input = LoginViewModel.Input(
            email: email.asObservable(),
            password: password.asObservable(),
            loginTrigger: loginTrigger.asObservable()
        )

        let output = loginViewModel.transform(input: input)
        let requestInFlight = scheduler.createObserver(Bool.self)
        let loginResult = scheduler.createObserver(Result<Bool, LoginError>.self)

        output.requestInFlight
            .drive(requestInFlight)
            .disposed(by: disposeBag)

        output.loginResult
            .drive(loginResult)
            .disposed(by: disposeBag)

        scheduler.start()

        let expectedRequestInFlight = Recorded.events([
            .next(0, false),
            .next(900, true),
            .next(900, false)
        ])

        let expectedLoginResult = Recorded.events([
            .next(900, Result<Bool, LoginError>.success(true))
        ])

        XCTAssertEqual(requestInFlight.events, expectedRequestInFlight)
        XCTAssertEqual(loginResult.events, expectedLoginResult)
    }
}
