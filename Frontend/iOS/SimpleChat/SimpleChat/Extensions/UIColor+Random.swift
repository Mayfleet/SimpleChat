//
// Created by Maxim Pervushin on 17/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import UIKit

extension UIColor {

    class var randomGrayscaleColor: UIColor {
        return UIColor(white: CGFloat(drand48()), alpha: 0.02)
    }

    var randomColor: UIColor {
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        getHue(&hue, saturation: &saturation, brightness: nil, alpha: nil)
        return UIColor(hue: hue, saturation: saturation, brightness: CGFloat(drand48() / 15) + 0.7, alpha: 1)
    }
}
