//
// Created by Maxim Pervushin on 05/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import Foundation

class ServerListDataSource: NSObject {

    public var onChange: (Void -> Void)?

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

