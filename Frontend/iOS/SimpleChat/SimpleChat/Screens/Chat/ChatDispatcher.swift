//
// Created by Maxim Pervushin on 14/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import Foundation

class ChatDispatcher {

    static let defaultDispatcher = ChatDispatcher()

    func chatWithConfiguration(configuration: ChatConfiguration) -> ChatLogic {
        if let chat = activeChats[configuration] {
            return chat
        }
        let chat = ChatLogic(configuration: configuration)
        activeChats[configuration] = chat
        return chat
    }

    private var activeChats = [ChatConfiguration: ChatLogic]()

    func connectChatWithConfiguration(configuration: ChatConfiguration) {
        let chat = chatWithConfiguration(configuration)
        chat.connect()
    }

    func disconnectChatWithConfiguration(configuration: ChatConfiguration) {
        let chat = chatWithConfiguration(configuration)
        chat.disconnect()
    }
}
