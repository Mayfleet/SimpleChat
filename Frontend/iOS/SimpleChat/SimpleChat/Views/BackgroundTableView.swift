//
// Created by Maxim Pervushin on 17/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import UIKit

@IBDesignable class BackgroundTableView: UITableView {

    override func drawRect(rect: CGRect) {
        super.drawRect(rect)

        let rows = 15
        let side = frame.size.width / CGFloat(rows)
        let columns = Int(frame.size.height / side) + 1

        let ctx = UIGraphicsGetCurrentContext()

        for row in 0.stride(to: rows, by: 1) {
            for column in 0.stride(to: columns, by: 1) {

                let rect = CGRect(x: CGFloat(row) * side, y: CGFloat(column) * side, width: side, height: side)
                CGContextSetFillColorWithColor(ctx, UIColor.randomGrayscaleColor.CGColor)
                CGContextFillRect(ctx, rect)

            }
        }
    }
}
