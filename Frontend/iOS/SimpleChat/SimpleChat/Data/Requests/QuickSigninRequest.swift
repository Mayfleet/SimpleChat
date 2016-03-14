//
// Created by Maxim Pervushin on 11/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import Foundation

struct QuickSigninRequest: Request {

    // MARK: QuickSigninRequest

    let token: String

    init(token: String) {
        self.token = token
    }


    // MARK: Request

    var cid: String {
        return NSUUID().UUIDString.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "-"))
    }

    var type: String {
        return "quick_signin"
    }

    var payload: [String:String] {
        return ["token": token]
    }
}
