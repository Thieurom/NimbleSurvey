//
//  LoginViewModel.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 08/05/2022.
//

import Foundation
import RxCocoa
import RxSwift

struct LoginError: Error, Equatable {
    let message: String
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
                    return .just(.failure(.init(message: R.string.localizable.login_fail_unknown())))
                }

                guard self.validateEmailAddress(email) else {
                    return .just(.failure(.init(message: R.string.localizable.login_fail_invalid_email())))
                }

                requestInFlight.accept(true)

                return self.nimbleSurveyClient.authenticate(email: email, password: password)
                    .do(onCompleted: {
                        requestInFlight.accept(false)
                    })
                    .andThen(.just(.success(true)))
                    .catch { _ in
                        requestInFlight.accept(false)
                        return .just(.failure(.init(message: R.string.localizable.login_fail_authen_fail())))
                    }
            }
            .asDriver(onErrorJustReturn: .failure(.init(message: R.string.localizable.login_fail_authen_fail())))

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
