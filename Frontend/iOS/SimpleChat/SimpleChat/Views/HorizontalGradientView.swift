//
// Created by Maxim Pervushin on 14/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import UIKit

@IBDesignable class HorizontalGradientView: UIView {

    @IBInspectable var startColor: UIColor = UIColor(white: 0, alpha: 0)
    @IBInspectable var endColor: UIColor = UIColor(white: 0, alpha: 1)
    @IBInspectable var start: CGFloat = 0
    @IBInspectable var end: CGFloat = 1

    override class func layerClass() -> AnyClass {
        return CAGradientLayer.self
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let gradientLayer = layer as? CAGradientLayer {
            gradientLayer.colors = [startColor.CGColor, endColor.CGColor]
            gradientLayer.startPoint = CGPoint(x: start, y: 0)
            gradientLayer.endPoint = CGPoint(x: end, y: 0)
        }
    }
}
