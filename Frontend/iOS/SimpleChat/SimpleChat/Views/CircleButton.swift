//
// Created by Maxim Pervushin on 11/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import UIKit

@IBDesignable class CircleButton: UIButton {

    override func layoutSubviews() {
        layer.cornerRadius = min(frame.height, frame.width) / 2
        super.layoutSubviews()
    }

    private func commonInit() {
        imageEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
        contentEdgeInsets = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
}
