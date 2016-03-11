//
// Created by Maxim Pervushin on 11/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import Foundation

protocol Request {
    var cid: String { get }
    var type: String { get }
    var payload: [String:String] { get }
}
