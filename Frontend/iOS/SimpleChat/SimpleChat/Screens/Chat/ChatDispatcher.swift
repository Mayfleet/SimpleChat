//
// Created by Maxim Pervushin on 14/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import Foundation
import SwiftyJSON

class ChatDispatcher {

    private (set) var chats = [Chat]()

    func addChat(chat: Chat?) -> Bool {
        if let chat = chat {
            chats.append(chat)
            save()
            return true
        } else {
            return false
        }
    }

    func removeChat(chat: Chat) -> Bool {
        if let index = chats.indexOf(chat) {
            chats.removeAtIndex(index)
            save()
            return true
        } else {
            return false
        }
    }

    func updateChat(chat: Chat) -> Bool {
        if let index = chats.indexOf(chat) {
            chats[index] = chat
            save()
            return true
        } else {
            return false
        }
    }

    init() {
        load()
    }

    private let storage = StorageDispatcher()

    private func save() {
        let packed = chats.map {
            return ["name": $0.configuration.name,
                    "backendURLString": $0.configuration.backendURL.absoluteString,
                    "autoconnect": $0.configuration.autoconnect]
        }

        if let jsonString = JSON(packed).rawString() {
            storage.writeString(jsonString, fileName: "chats")
        }
    }

    private func load() {
        if let
        content = storage.readString("chats"),
        jsons = JSON.parse(content).array {

            chats = jsons.flatMap {
                if let
                name = $0["name"].string,
                backendURLString = $0["backendURLString"].string,
                backendURL = NSURL(string: backendURLString),
                autoconnect = $0["autoconnect"].bool {
                    return Chat(configuration: ChatConfiguration(name: name, backendURL: backendURL, autoconnect: autoconnect))
                } else {
                    return nil
                }
            }
        } else {
            chats = [
                    ChatConfiguration(name: "Local:3000", backendURLString: "ws://localhost:3000/", autoconnect: true),
                    ChatConfiguration(name: "Local:3030", backendURLString: "ws://localhost:3030/"),
                    ChatConfiguration(name: "Local:3033", backendURLString: "ws://localhost:3033/"),
                    ChatConfiguration(name: "Local:3333", backendURLString: "ws://localhost:3333/"),
                    ChatConfiguration(name: "Heroku", backendURLString: "ws://mf-simple-chat.herokuapp.com:80/", autoconnect: true)
            ].flatMap {
                return Chat(configuration: $0)
            }
            save()
        }

        for chat in chats where chat.configuration.autoconnect {
            chat.connect()
        }
    }
}


