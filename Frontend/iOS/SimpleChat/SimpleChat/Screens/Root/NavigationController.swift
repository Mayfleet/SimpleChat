//
// Created by Maxim Pervushin on 16/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .Default
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationBar.barStyle = .Default
        navigationBar.barTintColor = UIColor.flatWhiteColor()
        hidesNavigationBarHairline = true
        view.backgroundColor = UIColor.flatGrayColor()
    }
}
