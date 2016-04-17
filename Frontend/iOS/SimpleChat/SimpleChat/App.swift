//
// Created by Maxim Pervushin on 15/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import UIKit

struct App {

    static var chatDispatcher: ChatDispatcher {
        return (UIApplication.sharedApplication().delegate as! AppDelegate).chatDispatcher
    }

    struct SegueIdentifiers {

        static let showChat = "ShowMessages"
        static let showLogIn = "ShowLogIn"
        static let showSignUp = "ShowSignUp"
    }
}
