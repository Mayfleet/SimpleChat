//
// Created by Maxim Pervushin on 11/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import Foundation

struct QuickSigninSuccessResponse: Response {

    // MARK: QuickSigninSuccessResponse

    private let _cid: String

    // MARK: Response

    init?(cid: String, payload: [String:AnyObject]) {
        _cid = cid
    }

    var cid: String {
        return _cid
    }

    var type: String {
        return "quick_signin_success"
    }
}
