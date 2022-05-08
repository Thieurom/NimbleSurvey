//
//  AppDelegate.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 07/05/2022.
//

import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let loginViewModel = LoginViewModel(
            authenticationManager: AuthenticationManager(
                clientId: clientId,
                clientSecret: clientSecret,
                authenticationAPI: AuthenticationAPI()
            )
        )

        let loginViewController = LoginViewController(viewModel: loginViewModel)
        window = window ?? UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = loginViewController
        window?.makeKeyAndVisible()

        return true
    }
}
