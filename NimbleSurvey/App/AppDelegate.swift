//
//  AppDelegate.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 07/05/2022.
//

import KeychainAccess
import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    lazy var nimbleSurveyClient = NimbleSurveyClient(
        clientId: clientId,
        clientSecret: clientSecret,
        credentialsStorage: Keychain(service: "co.survey-api.nimblehq")
    )

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = window ?? UIWindow(frame: UIScreen.main.bounds)
        window?.makeKeyAndVisible()

        if nimbleSurveyClient.hasCredentials() {
            Navigator.default.show(scene: .home, sender: nil, transition: .root)
        } else {
            Navigator.default.show(scene: .login, sender: nil, transition: .root)
        }

        setupNavigationBarAppearance()

        return true
    }
}

// MARK: - Globally customized

extension AppDelegate {
    private func setupNavigationBarAppearance() {
        // Make navigation bar transparent
        UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().backgroundColor = .clear
        UINavigationBar.appearance().tintColor = Theme.Color.secondaryBackground
        UINavigationBar.appearance().isTranslucent = true

        // Custom back button's image
        UINavigationBar.appearance().backIndicatorImage = R.image.ic_left_arrow()
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = R.image.ic_left_arrow()

        // Clear back button's text
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .normal)
        UIBarButtonItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.clear], for: .highlighted)
    }
}
