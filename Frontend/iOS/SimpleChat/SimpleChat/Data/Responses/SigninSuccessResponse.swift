//
// Created by Maxim Pervushin on 11/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import Foundation

struct SigninSuccessResponse: Response {

    // MARK: SigninSuccessResponse

    private let _cid: String
    let accessToken: String

    // MARK: Response

    init?(cid: String, payload: [String:AnyObject]) {
        if let accessToken = payload["accessToken"] as? String {
            _cid = cid
            self.accessToken = accessToken
        } else {
            return nil
        }
    }

    var cid: String {
        return _cid
    }

    var type: String {
        return "signin_success"
    }
}
