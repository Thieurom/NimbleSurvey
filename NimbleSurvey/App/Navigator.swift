//
//  Navigator.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 13/05/2022.
//

import UIKit

enum Scene {
    case login
    case home
    case survey
    case alert(title: String, message: String)
}

enum Transition {
    case root
    case navigation
    case modal
    case alert
}

protocol Navigatable: AnyObject {
    func show(scene: Scene, sender: UIViewController?, transition: Transition)
}

class Navigator: Navigatable {
    static let `default` = Navigator()
    private let appDelegate = UIApplication.shared.delegate as? AppDelegate

    private init() {}

    func show(scene: Scene, sender: UIViewController?, transition: Transition) {
        guard let viewController = viewController(from: scene) else {
            return
        }

        switch transition {
        case .root:
            UIApplication.shared.keyWindow?.rootViewController = viewController
        case .navigation:
            sender?.navigationController?.pushViewController(viewController, animated: true)
        case .modal:
            break
        case .alert:
            sender?.present(viewController, animated: true)
        }
    }

    func viewController(from scene: Scene) -> UIViewController? {
        // This seems weird to access a dependency from app delegate!
        // One solution is making `nimbleSurveyClient` Singleton (with a private initializer
        // with clientId and clientSecret from Plist file, as some SDK usually do).
        // Or use a Dependency Injection library like Resolver.
        guard let nimbleSurveyClient = appDelegate?.nimbleSurveyClient else {
            return nil
        }

        switch scene {
        case .login:
            let loginViewModel = LoginViewModel(nimbleSurveyClient: nimbleSurveyClient)
            return LoginViewController(viewModel: loginViewModel)

        case .home:
            let homeViewModel = HomeViewModel(nimbleSurveyClient: nimbleSurveyClient)
            let homeViewController = HomeViewController(viewModel: homeViewModel)
            let navigationController = UINavigationController(rootViewController: homeViewController)
            return navigationController

        case .survey:
            let surveyDetailViewModel = SurveyDetailViewModel(nimbleSurveyClient: nimbleSurveyClient)
            return SurveyDetailViewController(viewModel: surveyDetailViewModel)

        case let .alert(title, message):
            let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let action = UIAlertAction(title: R.string.localizable.alert_ok(), style: .default)
            alertController.addAction(action)
            
            return alertController
        }
    }
}
