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

        return true
    }
}
