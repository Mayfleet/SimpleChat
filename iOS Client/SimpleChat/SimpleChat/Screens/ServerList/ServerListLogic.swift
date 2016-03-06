//
// Created by Maxim Pervushin on 05/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ServerListLogic: NSObject {

    var onChange: (Void -> Void)?

    func addServerWithName(name: String?, backendURLString: String?) -> Bool {
        if let
        name = name,
        backendURLString = backendURLString,
        backendURL = NSURL(string: backendURLString) {

            servers.append(Server(name: name, backendURL: backendURL))
            save()
            return true
        } else {
            return false
        }
    }

    func removeServerAtIndex(index: Int) -> Bool {
        servers.removeAtIndex(index)
        save()
        return true
    }

    private (set) var servers = [Server]()

    private func load() {
        if let
        jsonString = StorageDispatcher.defaultDispatcher.readString("servers"),
        jsonArray = JSON.parse(jsonString).array {
            var serversTemp = [Server]()
            for json in jsonArray {
                if let
                name = json["name"].string,
                backendURLString = json["backendURLString"].string,
                backendURL = NSURL(string: backendURLString) {
                    serversTemp.append(Server(name: name, backendURL: backendURL))
                }
            }
            servers = serversTemp

        } else {
            servers = [
                    Server(name: "Local", backendURL: NSURL(string: "ws://localhost:3000/")!),
                    Server(name: "Heroku", backendURL: NSURL(string: "ws://mf-simple-chat.herokuapp.com:80/")!)
            ]
            save()
        }
    }

    private func save() {
        var packed = [[String: String]]()
        for server in servers {
            packed.append(["name": server.name, "backendURLString": server.backendURL.absoluteString])
        }
        if let jsonString = JSON(packed).rawString() {
            StorageDispatcher.defaultDispatcher.writeString(jsonString, fileName: "servers")
        }
    }

    override init() {
        super.init()
        load()
    }
}
