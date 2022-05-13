//
//  LoginViewModel.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 08/05/2022.
//

import Foundation
import RxCocoa
import RxSwift

struct LoginError: Error {
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
                // Naive validation instead of using some complex Regex from StackOverflow!
                return email.contains("@") && !password.isEmpty
            }
            .startWith(false)
            .asDriver(onErrorJustReturn: false)

        let loginResult = input.loginTrigger
            .withLatestFrom(formInputs)
            .flatMapLatest { [weak self] email, password -> Single<Result<Bool, LoginError>> in
                guard let self = self else {
                    return .error(LoginError(message: R.string.localizable.login_fail_unknown()))
                }

                return self.nimbleSurveyClient.authenticate(email: email, password: password)
                    .andThen(.just(.success(true)))
                    .catch { _ in
                        throw LoginError(message: R.string.localizable.login_fail_authen_fail())
                    }
            }
            .asDriver(onErrorJustReturn: .failure(.init(message: R.string.localizable.login_fail_authen_fail())))

        return Output(
            loginEnabled: loginEnabled,
            loginResult: loginResult
        )
    }
}
