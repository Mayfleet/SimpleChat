//
// Created by Maxim Pervushin on 11/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import Foundation

struct SignupRequest: Request {

    // MARK: SignupRequest

    let username: String
    let password: String

    init(username: String, password: String) {
        self.username = username
        self.password = password
    }

    init?(username: String?, password: String?) {
        if let username = username, password = password {
            self.init(username: username, password: password)
        }
        return nil
    }

    // MARK: Request

    var cid: String {
        return NSUUID().UUIDString.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "-"))
    }

    var type: String {
        return "signup"
    }

    var payload: [String:String] {
        return [
                "username": username,
                "password": password
        ]
    }
}
