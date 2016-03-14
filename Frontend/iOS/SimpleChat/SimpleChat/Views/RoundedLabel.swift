//
// Created by Maxim Pervushin on 14/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import UIKit

@IBDesignable class RoundedLabel: UILabel {

    override func layoutSubviews() {
        clipsToBounds = true
        layer.cornerRadius = min(frame.height, frame.width) / 2
        super.layoutSubviews()
    }
}
