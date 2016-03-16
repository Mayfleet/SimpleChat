//
// Created by Maxim Pervushin on 16/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        hidesNavigationBarHairline = true
        navigationBar.barStyle = .Black
        navigationBar.barTintColor = UIColor.flatPurpleColor()
        navigationBar.tintColor = UIColor.flatWhiteColor()
        view.backgroundColor = UIColor.flatPurpleColorDark()
    }
}
