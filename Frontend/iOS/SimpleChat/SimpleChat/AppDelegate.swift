//
//  AppDelegate.swift
//  SimpleChat
//
//  Created by Maxim Pervushin on 01/03/16.
//  Copyright © 2016 Maxim Pervushin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        print("Chats: \(ChatDispatcher.defaultDispatcher.chats.count)")

        return true
    }
}
