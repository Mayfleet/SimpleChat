//
// Created by Maxim Pervushin on 05/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ServerListLogic: NSObject {

    var onChange: (Void -> Void)?

    func addConfigurationWithName(name: String?, backendURLString: String?) -> Bool {
        if let
        name = name,
        backendURLString = backendURLString,
        backendURL = NSURL(string: backendURLString) {

            configurations.append(ChatConfiguration(name: name, backendURL: backendURL))
            save()
            return true
        } else {
            return false
        }
    }

    func removeConfigurationAtIndex(index: Int) -> Bool {
        configurations.removeAtIndex(index)
        save()
        return true
    }

    func removeConfiguration(configuration: ChatConfiguration) -> Bool {
        if let index = configurations.indexOf(configuration) {
            configurations.removeAtIndex(index)
            save()
            return true

        } else {
            return false
        }
    }

    private (set) var configurations = [ChatConfiguration]()

    func load() {
        if let
        jsonString = StorageDispatcher.defaultDispatcher.readString("servers"),
        jsonArray = JSON.parse(jsonString).array {
            var serversTemp = [ChatConfiguration]()
            for json in jsonArray {
                if let
                name = json["name"].string,
                backendURLString = json["backendURLString"].string,
                backendURL = NSURL(string: backendURLString),
                autoconnect = json["autoconnect"].bool {
                    serversTemp.append(ChatConfiguration(name: name, backendURL: backendURL, autoconnect: autoconnect))
                }
            }
            configurations = serversTemp

        } else {
            configurations = [
                    ChatConfiguration(name: "Local:3000", backendURL: NSURL(string: "ws://localhost:3000/")!, autoconnect: true),
                    ChatConfiguration(name: "Local:3030", backendURL: NSURL(string: "ws://localhost:3030/")!),
                    ChatConfiguration(name: "Local:3033", backendURL: NSURL(string: "ws://localhost:3033/")!),
                    ChatConfiguration(name: "Local:3333", backendURL: NSURL(string: "ws://localhost:3333/")!),
                    ChatConfiguration(name: "Heroku", backendURL: NSURL(string: "ws://mf-simple-chat.herokuapp.com:80/")!, autoconnect: true)
            ]
            save()
        }

//        for configuration in configurations where configuration.autoconnect {
//            ChatDispatcher.defaultDispatcher.chatWithConfiguration(configuration).connect()
//        }
    }

    func save() {
        var packed = [[String: AnyObject]]()
        for configuration in configurations {
            packed.append(["name": configuration.name, "backendURLString": configuration.backendURL.absoluteString, "autoconnect": configuration.autoconnect])
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
