//
//  LoginViewModel.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 08/05/2022.
//

import Foundation
import RxCocoa
import RxSwift

enum LoginError: Error, Equatable {
    case invalidEmail
    case authenticationFail
    case unknown

    var message: String {
        switch self {
        case .invalidEmail:
            return R.string.localizable.login_fail_invalid_email()
        case .authenticationFail:
            return R.string.localizable.login_fail_authen_fail()
        case .unknown:
            return R.string.localizable.unknown_error()
        }
    }
}

class LoginViewModel: ViewModelType {

    // MARK: - Nested types

    struct Input {
        let email: Observable<String>
        let password: Observable<String>
        let loginTrigger: Observable<Void>
    }

    struct Output {
        let loginEnabled: Driver<Bool>
        let loginResult: Driver<Result<Bool, LoginError>>
        let requestInFlight: Driver<Bool>
    }

    // MARK: - Dependencies

    private let nimbleSurveyClient: NimbleSurveyClientType

    init(nimbleSurveyClient: NimbleSurveyClientType) {
        self.nimbleSurveyClient = nimbleSurveyClient
    }

    func transform(input: Input) -> Output {
        let formInputs = Observable.combineLatest(input.email, input.password)

        let loginEnabled = formInputs
            .map { email, password in
                return !email.isEmpty && !password.isEmpty
            }
            .startWith(false)
            .asDriver(onErrorJustReturn: false)

        let requestInFlight = BehaviorRelay(value: false)

        let loginResult = input.loginTrigger
            .withLatestFrom(formInputs)
            .flatMapLatest { [weak self] email, password -> Single<Result<Bool, LoginError>> in
                guard let self = self else {
                    return .just(.failure(.unknown))
                }

                guard self.validateEmailAddress(email) else {
                    return .just(.failure(.invalidEmail))
                }

                requestInFlight.accept(true)

                return self.nimbleSurveyClient.authenticate(email: email, password: password)
                    .do(onCompleted: {
                        requestInFlight.accept(false)
                    })
                    .andThen(.just(.success(true)))
                    .catch { error in
                        requestInFlight.accept(false)

                        switch error {
                        case NimbleSurveyError.authenticationFailed:
                            return .just(.failure(.authenticationFail))
                        default:
                            return .just(.failure(.unknown))
                        }
                    }
            }
            .asDriver(onErrorJustReturn: .failure(.unknown))

        return Output(
            loginEnabled: loginEnabled,
            loginResult: loginResult,
            requestInFlight: requestInFlight.asDriver()
        )
    }
}

// MARK: - Helpers

extension LoginViewModel {
    private func validateEmailAddress(_ email: String) -> Bool {
        // There're many, yet complex answers for this on StackOverflow.
        // I like thesimple one (https://www.advancedswift.com/regular-expressions/)
        //
        // One or more characters followed by an "@",
        // then one or more characters followed by a ".",
        // and finishing with one or more characters
        let emailPattern = #"^\S+@\S+\.\S+$"#
        return email.range(of: emailPattern, options: .regularExpression) != nil
    }
}
