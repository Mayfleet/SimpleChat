//
// Created by Maxim Pervushin on 11/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import Foundation

struct SetPointerRequest: Request {

    // MARK: SetPointerRequest

    let pointer: Int

    init(pointer: Int) {
        self.pointer = pointer
    }

    // MARK: Request

    var cid: String {
        return NSUUID().UUIDString.stringByTrimmingCharactersInSet(NSCharacterSet(charactersInString: "-"))
    }

    var type: String {
        return "set_pointer"
    }

    var payload: [String:String] {
        return ["pointer": "\(pointer)"]
    }
}
