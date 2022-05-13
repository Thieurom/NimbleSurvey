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
}

enum Transition {
    case root
    case navigation
    case modal
}

protocol Navigatable: AnyObject {
    func show(scene: Scene, sender: UIViewController?, transition: Transition)
}

class Navigator: Navigatable {
    static let `default` = Navigator()
    private let appDelegate = UIApplication.shared.delegate as? AppDelegate

    private init() {}

    func show(scene: Scene, sender: UIViewController?, transition: Transition) {
        switch transition {
        case .root:
            UIApplication.shared.keyWindow?.rootViewController = viewController(from: scene)
        case .navigation:
            break
        case .modal:
            break
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
            return HomeViewController(viewModel: homeViewModel)
        }
    }
}
