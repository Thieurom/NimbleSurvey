//
//  AppDelegate.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 07/05/2022.
//

import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    lazy var nimbleSurveyClient = NimbleSurveyClient(
        clientId: clientId,
        clientSecret: clientSecret
    )

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let loginViewModel = LoginViewModel(nimbleSurveyClient: nimbleSurveyClient)
        let loginViewController = LoginViewController(viewModel: loginViewModel)

        window = window ?? UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = loginViewController
        window?.makeKeyAndVisible()

        return true
    }
}
