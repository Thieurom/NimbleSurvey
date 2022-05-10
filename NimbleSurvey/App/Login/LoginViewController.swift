//
//  LoginViewController.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 07/05/2022.
//

import RxCocoa
import RxSwift
import SnapKit
import UIKit

class LoginViewController: UIViewController {

    // MARK: - Public views

    lazy var emailTextField = formInputField(
        placeholder: R.string.localizable.login_email_placeholder()
    ).apply {
        $0.autocapitalizationType = .none
        $0.autocorrectionType = .no
        $0.paddingLeft(UIView(frame: .init(x: 0, y: 0, width: 12, height: $0.frame.height)))
        $0.paddingRight(UIView(frame: .init(x: 0, y: 0, width: 12, height: $0.frame.height)))
    }

    lazy var passwordTextField = formInputField(
        placeholder: R.string.localizable.login_password_placeholder()
    ).apply {
        $0.isSecureTextEntry = true
        $0.paddingLeft(UIView(frame: .init(x: 0, y: 0, width: 12, height: $0.frame.height)))
        $0.paddingRight(forgotPasswordButton)
    }

    lazy var forgotPasswordButton = UIButton().apply {
        $0.setTitle(R.string.localizable.login_forgot_password(), for: .normal)
        $0.titleLabel?.font = Theme.Font.small
        $0.setTitleColor(.white.withAlphaComponent(0.5), for: .normal)
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: 0, right: 12)
    }

    lazy var loginButton = UIButton(type: .system).apply {
        $0.backgroundColor = .white
        $0.setTitle(R.string.localizable.login_login_button(), for: .normal)
        $0.titleLabel?.font = Theme.Font.title
        $0.setTitleColor(.black, for: .normal)
        $0.setTitleColor(.gray, for: .disabled)
        $0.roundingCorner(10)
    }

    // MARK: - Internal views

    private lazy var backgroundImageView = UIImageView().apply {
        $0.contentMode = .scaleAspectFill
        $0.image = R.image.background()
    }

    private lazy var overlayView = LinearGradientView(
        colors: [
            .black.withAlphaComponent(0),
            .black
        ]
    )

    private lazy var blurView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .dark)
        return UIVisualEffectView(effect: blurEffect)
    }()

    private lazy var logoImageView = UIImageView().apply {
        $0.contentMode = .scaleAspectFit
        $0.image = R.image.logo()
    }

    private lazy var logoContainerView = UIView()

    private lazy var formStackView = UIStackView().apply {
        $0.axis = .vertical
        $0.spacing = 20
        $0.distribution = .fillEqually
    }

    // MARK: - Private properties

    private var formCenterYConstraint: Constraint?
    private var formBottomConstraint: Constraint?
    private let disposeBag = DisposeBag()

    // MARK: - Initialization

    private let viewModel: LoginViewModel

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - View lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        observeKeyboard()
        animateViewsIn()

        bindViewModel()
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - Setup views

extension LoginViewController {
    private func setupViews() {
        // Add views to hierarchy
        [emailTextField, passwordTextField, loginButton]
            .forEach(formStackView.addArrangedSubview)

        logoContainerView.addSubview(logoImageView)

        view.addSubviews(
            backgroundImageView,
            overlayView,
            blurView,
            logoContainerView,
            formStackView
        )

        // Constraint
        [backgroundImageView, overlayView, blurView]
            .forEach {
                $0.snp.makeConstraints { make in
                    make.top.leading.trailing.bottom.equalToSuperview()
                }
            }

        logoImageView.snp.makeConstraints { make in
            make.center.equalTo(view)
        }

        logoContainerView.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(-8)
            } else {
                make.top.equalTo(view.layoutMarginsGuide.snp.topMargin).offset(-8)
            }

            make.bottom.equalTo(formStackView.snp.top).offset(-8)
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
        }

        formStackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(24)
            make.trailing.equalToSuperview().offset(-24)
            formCenterYConstraint = make.centerY.equalToSuperview().constraint
            formBottomConstraint = make.bottom.equalToSuperview().constraint
        }

        formCenterYConstraint?.activate()
        formBottomConstraint?.deactivate()

        [emailTextField, passwordTextField, loginButton]
            .forEach {
                $0.snp.makeConstraints { make in
                    make.height.equalTo(56)
                }
            }
    }

    private func animateViewsIn() {
        formStackView.alpha = 0
        blurView.alpha = 0
        logoImageView.alpha = 0
        logoImageView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)

        UIView.animate(withDuration: 0.5, delay: 1, options: [.curveEaseIn]) {
            self.logoImageView.alpha = 1
        } completion: { _ in
            self.logoImageView.snp.remakeConstraints { make in
                make.height.lessThanOrEqualTo(40)
                make.top.leading.greaterThanOrEqualToSuperview()
                make.trailing.bottom.lessThanOrEqualToSuperview()
                make.center.equalToSuperview()
            }

            UIView.animate(withDuration: 0.4, delay: 0.5, options: [.curveEaseIn]) {
                self.formStackView.alpha = 1
                self.blurView.alpha = 1
                self.logoContainerView.layoutIfNeeded()
                self.logoImageView.transform = .identity
            }
        }
    }
}

// MARK: - Handle keyboard

extension LoginViewController {
    private func observeKeyboard() {
        // swiftlint:disable:next line_length
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.handleKeyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        // swiftlint:disable:next line_length
        NotificationCenter.default.addObserver(self, selector: #selector(LoginViewController.handleKeyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }

    @objc
    private func handleKeyboardWillShow(_ notification: Notification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue) else {
            return
        }

        let keyboardHeight = keyboardSize.cgRectValue.height
        // We want the form is a little higher than the keyboard.
        let avoidingSpacing = keyboardHeight + 20
        let belowFormSpacing = (view.frame.height - formStackView.frame.height) / 2

        guard belowFormSpacing < avoidingSpacing else {
            return
        }

        formCenterYConstraint?.deactivate()
        formBottomConstraint?.activate()
        formBottomConstraint?.update(offset: -avoidingSpacing)

        UIView.animate(withDuration: 0.15) {
            self.view.layoutIfNeeded()
        }
    }

    @objc
    private func handleKeyboardWillHide(_ notification: Notification) {
        formBottomConstraint?.deactivate()
        formCenterYConstraint?.activate()

        UIView.animate(withDuration: 0.15) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - Bind view model

extension LoginViewController {
    private func bindViewModel() {
        let input = LoginViewModel.Input(
            email: emailTextField.rx.text.compactMap { $0 },
            password: passwordTextField.rx.text.compactMap { $0 },
            loginTrigger: loginButton.rx.tap.asObservable()
        )

        let output = viewModel.transform(input: input)

        output.loginEnabled
            .drive(loginButton.rx.isEnabled)
            .disposed(by: disposeBag)

        output.loginEnabled
            .drive(loginButton.rx.isUserInteractionEnabled)
            .disposed(by: disposeBag)

        output.loginResult
            .drive(onNext: { result in
                switch result {
                case .success:
                    // TODO: Go to HOME
                    print("Success")
                case.failure(let error):
                    // TODO: Show toast
                    print("Fail: \(error)")
                }
            })
            .disposed(by: disposeBag)
    }
}

// MARK: - Helpers

extension LoginViewController {
    private func formInputField(placeholder: String) -> UITextField {
        let textField = UITextField()

        textField.backgroundColor = .white.withAlphaComponent(0.18)
        textField.textColor = Theme.Color.primaryText
        textField.roundingCorner(12)
        textField.font = Theme.Font.body

        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: UIColor.white.withAlphaComponent(0.3),
                .font: Theme.Font.body
            ]
        )

        return textField
    }
}
