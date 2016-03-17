//
// Created by Maxim Pervushin on 17/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import UIKit

extension UIColor {

    class var randomGrayscaleColor: UIColor {
        return UIColor(white: CGFloat(drand48()), alpha: 0.02)
    }
}
