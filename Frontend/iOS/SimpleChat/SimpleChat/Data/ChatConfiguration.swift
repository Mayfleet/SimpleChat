//
// Created by Maxim Pervushin on 05/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import Foundation

class ChatConfiguration {

    var name: String
    var backendURL: NSURL
    var autoconnect: Bool

    init(name: String, backendURL: NSURL, autoconnect: Bool = false) {
        self.name = name
        self.backendURL = backendURL
        self.autoconnect = autoconnect
    }

    convenience init?(name: String?, backendURL: NSURL?, autoconnect: Bool = false) {
        guard let name = name, backendURL = backendURL else {
            return nil
        }
        self.init(name: name, backendURL: backendURL, autoconnect: autoconnect)
    }

    convenience init?(name: String?, backendURLString: String?, autoconnect: Bool = false) {
        guard let name = name, backendURLString = backendURLString, backendURL = NSURL(string: backendURLString) else {
            return nil
        }
        self.init(name: name, backendURL: backendURL, autoconnect: autoconnect)
    }

//    convenience init?(name: String?, backendURLString: String?, autoconnect: Bool?) {
//        guard let name = name, backendURLString = backendURLString, backendURL = NSURL(string: backendURLString) else {
//            return nil
//        }
//        self.init(name: name, backendURL: backendURL, autoconnect: false)
//    }
}

extension ChatConfiguration: Hashable {

    var hashValue: Int {
        return name.hashValue ^ backendURL.hashValue // Ignore autoconnect flag here
    }
}

func ==(lhs: ChatConfiguration, rhs: ChatConfiguration) -> Bool {
    return lhs.name == rhs.name && lhs.backendURL == rhs.backendURL
}
