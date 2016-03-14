//
// Created by Maxim Pervushin on 11/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import Foundation

struct SigninRequest: Request {

    // MARK: SigninRequest

    let username: String
    let password: String

    init(username: String, password: String) {
        self.username = username
        self.password = password
    }

    // MARK: Request

    var cid: String {
        return NSUUID().UUIDString.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "-"))
    }

    var type: String {
        return "signin"
    }

    var payload: [String:String] {
        return [
                "username": username,
                "password": password
        ]
    }
}
