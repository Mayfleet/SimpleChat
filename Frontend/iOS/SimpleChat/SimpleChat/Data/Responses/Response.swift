//
// Created by Maxim Pervushin on 11/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import Foundation

protocol Response {
    init?(cid: String, payload: [String:String])
    var cid: String { get }
    var type: String { get }
}

struct SignupSuccessResponse: Response {

    // MARK: SignupSuccessResponse

    private let _cid: String
    let username: String
    let userId: String
    let userToken: String

    // MARK: Response

    init?(cid: String, payload: [String:String]) {
        if let
        username = payload["username"],
        userId = payload["userId"],
        userToken = payload["userToken"] {
            _cid = cid
            self.username = username
            self.userId = userId
            self.userToken = userToken
        } else {
            return nil
        }
    }

    var cid: String {
        return _cid
    }

    var type: String {
        return "signup_success"
    }
}
