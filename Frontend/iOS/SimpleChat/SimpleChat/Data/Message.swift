//
// Created by Maxim Pervushin on 09/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class Message: NSObject, JSQMessageData {

    private var id_: String
    private var sender_: String
    private var text_: String
    private var clientDate_: NSDate
    private var serverDate_: NSDate?

    init(id: String, sender: String, text: String, clientDate: NSDate, serverDate: NSDate?) {
        self.id_ = id
        self.sender_ = sender
        self.text_ = text
        self.clientDate_ = clientDate
        self.serverDate_ = serverDate
    }

    var id: String {
        return id_
    }

    var serverDate: NSDate? {
        return serverDate_
    }

    // MARK: JSQMessageData

    func senderId() -> String! {
        return sender_
    }

    func senderDisplayName() -> String! {
        return sender_
    }

    func date() -> NSDate! {
        return clientDate_
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

enum MessageKey: String {
    case Sender = "senderId"
    case Text = "text"
}

extension Message {

    convenience init?(dictionary: [String: AnyObject]?) {
        if let
        sender = dictionary?["senderId"] as? String,
        text = dictionary?["text"] as? String {

            // TODO: Get id from dictionary
            // TODO: Get client date from dictionary
            // TODO: Get server date from dictionary

            self.init(id: NSUUID().UUIDString, sender: sender, text: text, clientDate: NSDate(), serverDate: nil)
        } else {
            return nil
        }
    }

}