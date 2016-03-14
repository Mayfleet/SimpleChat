//
// Created by Maxim Pervushin on 05/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import Foundation

struct ServerConfiguration {

    let name: String
    let backendURL: NSURL

    init(name: String, backendURL: NSURL) {
        self.name = name
        self.backendURL = backendURL
    }
}
