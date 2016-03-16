//
//  BackgroundView.swift
//  BackgroundResearch
//
//  Created by Maxim Pervushin on 16/03/16.
//  Copyright © 2016 Maxim Pervushin. All rights reserved.
//

import UIKit

@IBDesignable class BackgroundView: UIView {

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        let rows = 15
        let side = frame.size.width / CGFloat(rows)
        let columns = Int(frame.size.height / side) + 1
        
        let ctx = UIGraphicsGetCurrentContext()
        
        for row in 0.stride(to: rows, by: 1) {
            for column in 0.stride(to: columns, by: 1) {
                
                let rect = CGRect(x: CGFloat(row) * side, y: CGFloat(column) * side, width: side, height: side)
                CGContextSetFillColorWithColor(ctx, UIColor.randomColor.CGColor)
                CGContextFillRect(ctx, rect)
                
            }
        }
    }

}

extension UIColor {
    
    class var randomColor : UIColor {
//        let randomRed: CGFloat = CGFloat(drand48())
//        let randomGreen: CGFloat = CGFloat(drand48())
//        let randomBlue: CGFloat = CGFloat(drand48())
//        return UIColor(red: randomRed, green: randomGreen, blue: randomBlue, alpha: 1.0)
        return UIColor(white: CGFloat(drand48()), alpha: 1.0)
    }

}