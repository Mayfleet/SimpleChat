//
// Created by Maxim Pervushin on 16/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import UIKit

@IBDesignable class RoundedButton: UIButton {

    override func layoutSubviews() {
        layer.cornerRadius = 3
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
