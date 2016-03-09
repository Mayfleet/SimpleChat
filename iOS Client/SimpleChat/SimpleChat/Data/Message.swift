//
// Created by Maxim Pervushin on 09/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class Message: NSObject, JSQMessageData {

    var sender_: String
    var text_: String
    var date_: NSDate

    init(sender: String, text: String, date: NSDate) {
        self.sender_ = sender
        self.text_ = text
        self.date_ = date
    }

    // MARK: JSQMessageData

    func senderId() -> String! {
        return sender_
    }

    func senderDisplayName() -> String! {
        return sender_
    }

    func date() -> NSDate! {
        return date_
    }

    func isMediaMessage() -> Bool {
        return false
    }

    func messageHash() -> UInt {
        return UInt(hash)
    }

    func text() -> String! {
        return text_
    }
}
