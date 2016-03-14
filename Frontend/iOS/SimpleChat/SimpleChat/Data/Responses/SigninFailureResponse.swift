//
// Created by Maxim Pervushin on 11/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import Foundation

struct SigninFailureResponse: Response {

    // MARK: SigninFailureResponse

    private let _cid: String
    let code: String

    // MARK: Response

    init?(cid: String, payload: [String:AnyObject]) {
        if let code = payload["code"] as? String {
            _cid = cid
            self.code = code
        } else {
            return nil
        }
    }

    var cid: String {
        return _cid
    }

    var type: String {
        return "signin_failure"
    }
}
