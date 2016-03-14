//
// Created by Maxim Pervushin on 11/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import Foundation

protocol Response {
    init?(cid: String, payload: [String:AnyObject])
    var cid: String { get }
    var type: String { get }
}
