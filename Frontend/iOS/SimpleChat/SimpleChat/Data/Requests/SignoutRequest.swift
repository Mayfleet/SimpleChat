//
// Created by Maxim Pervushin on 11/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import Foundation

struct SignoutRequest: Request {

    // MARK: Request

    var cid: String {
        return NSUUID().UUIDString.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "-"))
    }

    var type: String {
        return "signout"
    }

    var payload: [String:String] {
        return [:]
    }
}
