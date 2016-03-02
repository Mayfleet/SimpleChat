//
// Created by Maxim Pervushin on 01/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import JSQMessagesViewController

class Message: NSObject, JSQMessageData {
    var text_: String
    var sender_: String
    var date_: NSDate
    var imageUrl_: String?

    convenience init(text: String?, sender: String?) {
        self.init(text: text, sender: sender, imageUrl: nil)
    }

    init(text: String?, sender: String?, imageUrl: String?) {
        self.text_ = text!
        self.sender_ = sender!
        self.date_ = NSDate()
        self.imageUrl_ = imageUrl
    }

    // MARK: JSQMessageData

    public func senderId() -> String! {
        return sender_
    }

    public func senderDisplayName() -> String! {
        return sender_
    }

    public func date() -> NSDate! {
        return date_
    }

    public func isMediaMessage() -> Bool {
        return false
    }

    public func messageHash() -> UInt {
        return 0 // UInt(text_.hashValue)
    }

    public func text() -> String! {
        return text_
    }
}
