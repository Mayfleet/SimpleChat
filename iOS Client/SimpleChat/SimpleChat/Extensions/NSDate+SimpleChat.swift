//
// Created by Maxim Pervushin on 09/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import Foundation

extension NSDate {

    var mediumDateString: String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .NoStyle
        return formatter.stringFromDate(self)
    }

    var mediumTimeString: String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .NoStyle
        formatter.timeStyle = .MediumStyle
        return formatter.stringFromDate(self)
    }

    var mediumString: String {
        let formatter = NSDateFormatter()
        formatter.dateStyle = .MediumStyle
        formatter.timeStyle = .MediumStyle
        return formatter.stringFromDate(self)
    }

}