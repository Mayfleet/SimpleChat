//
// Created by Maxim Pervushin on 16/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import UIKit

@IBDesignable class RoundedView: UIView {

    override func layoutSubviews() {
        layer.cornerRadius = 3
        super.layoutSubviews()
    }
}
