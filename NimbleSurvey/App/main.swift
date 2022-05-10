//
//  main.swift
//  NimbleSurvey
//
//  Created by Doan Le Thieu on 10/05/2022.
//

import UIKit

// To improve unit test performance, don't instantiate AppDelegate
let isRunningTests = NSClassFromString("XCTestCase") != nil
let appDelegateClass = isRunningTests ? nil : NSStringFromClass(AppDelegate.self)
UIApplicationMain(CommandLine.argc, CommandLine.unsafeArgv, nil, appDelegateClass)
