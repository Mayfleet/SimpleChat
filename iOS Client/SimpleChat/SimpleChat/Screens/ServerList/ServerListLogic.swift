//
// Created by Maxim Pervushin on 05/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import Foundation

class ServerListLogic: NSObject {

    var onChange: (Void -> Void)?

    func addServerWithName(name: String?, backendURLString: String?) -> Bool {
        if let
        name = name,
        backendURLString = backendURLString,
        backendURL = NSURL(string: backendURLString) {

            servers.append(Server(name: name, backendURL: backendURL))
            return true
        } else {
            return false
        }
    }

    func removeServerAtIndex(index: Int) -> Bool {
        servers.removeAtIndex(index)
        return true
    }

    private (set) var servers = [Server]()

    private func load() {
        if servers.count == 0 {
            servers = [
                    Server(name: "Local", backendURL: NSURL(string: "ws://localhost:3000/")!),
                    Server(name: "Heroku", backendURL: NSURL(string: "ws://mf-simple-chat.herokuapp.com:80/")!)
            ]
        }
    }

    private func save() {

    }

    override init() {
        super.init()
        load()
    }
}

