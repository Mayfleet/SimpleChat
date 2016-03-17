//
//  AppDelegate.swift
//  SimpleChat
//
//  Created by Maxim Pervushin on 01/03/16.
//  Copyright © 2016 Maxim Pervushin. All rights reserved.
//

import UIKit
import JSQMessagesViewController

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        print("Chats: \(App.chatDispatcher.chats.count)")
        initAppearance()

        return true
    }

    private func initAppearance() {
        UIView.appearance().tintColor = UIColor.flatBlackColor()

        UINavigationBar.appearance().barStyle = .Black
        UINavigationBar.appearance().barTintColor = UIColor.flatPurpleColor()
        UINavigationBar.appearance().tintColor = UIColor.flatWhiteColor()

        JSQMessagesInputToolbar.appearance().barStyle = .Black
        JSQMessagesInputToolbar.appearance().barTintColor = UIColor.flatPurpleColor()
        JSQMessagesInputToolbar.appearance().tintColor = UIColor.flatWhiteColor()

        UIButton.appearanceWhenContainedInInstancesOfClasses([JSQMessagesInputToolbar.self]).tintColor = UIColor.flatWhiteColor()
        UIButton.appearanceWhenContainedInInstancesOfClasses([JSQMessagesInputToolbar.self]).setTitleColor(UIColor.flatWhiteColor(), forState: .Normal)
        UIButton.appearanceWhenContainedInInstancesOfClasses([JSQMessagesInputToolbar.self]).setTitleColor(UIColor.flatWhiteColor(), forState: .Highlighted)

        BackgroundTableView.appearance().backgroundColor = UIColor.flatPurpleColorDark()
        BackgroundView.appearance().backgroundColor = UIColor.flatPurpleColorDark()
    }
}
