//
// Created by Maxim Pervushin on 11/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import Foundation

struct SetPointerFailureResponse: Response {

    // MARK: SetPointerFailureResponse

    private let _cid: String
    let code: String
    let details: [String: String]

    // MARK: Response

    init?(cid: String, payload: [String:AnyObject]) {
        if let
        code = payload["code"] as? String,
        details = payload["details"] as? [String: String] {
            _cid = cid
            self.code = code
            self.details = details
        } else {
            return nil
        }
    }

    var cid: String {
        return _cid
    }

    var type: String {
        return "set_pointer_failure"
    }
}
