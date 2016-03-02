//
//  MessagesViewController.swift
//  SimpleChat
//
//  Created by Maxim Pervushin on 01/03/16.
//  Copyright © 2016 Maxim Pervushin. All rights reserved.
//

import JSQMessagesViewController
import Starscream
import SwiftyJSON

class MessagesViewController: JSQMessagesViewController {

    var socket: WebSocket!
    var messages = [Message]()

    override func viewDidLoad() {
        super.viewDidLoad()
        senderId = "SimpleChat"
        senderDisplayName = "Simple Chat"

        socket = WebSocket(url: NSURL(string: "ws://localhost:3000/")!, protocols: ["http"])
        socket.delegate = self
        socket.connect()
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.row]
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
//        if messages[indexPath.row].senderId() == senderId {
        if indexPath.row % 2 == 0 {
            return JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor().colorWithAlphaComponent(0.5))
        } else {
            return JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.blueColor().colorWithAlphaComponent(0.5))
        }
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        //        if messages[indexPath.row].senderId() == senderId {
        if indexPath.row % 2 == 0 {
            return JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "AvatarOutgoing"), diameter: 30)
        } else {
            return JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "AvatarIncoming"), diameter: 30)
        }
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell

        let message = messages[indexPath.item]
//        if message.senderId() == senderId {
        if indexPath.row % 2 == 0 {
            cell.textView?.textColor = UIColor.blackColor()
        } else {
            cell.textView?.textColor = UIColor.whiteColor()
        }

        return cell
    }

    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        socket.writeString(text)
    }
}

extension MessagesViewController: WebSocketDelegate {

    func websocketDidConnect(socket: WebSocket) {
        print("connected")
    }

    func websocketDidDisconnect(socket: WebSocket, error: NSError?) {
        print("disconnected: \(error)")
    }

    func websocketDidReceiveMessage(socket: WebSocket, text: String) {
        let json = JSON.parse(text)

        switch json["type"] {
        case "history":
            let data = json["data"]
            for message in data {
                let sender = messages.count % 2 == 1 ? "SimpleChat" : "Empty"
                messages.append(Message(text: message.1.string!, sender: sender, imageUrl: nil))
            }
            dispatch_async(dispatch_get_main_queue(), {
                () -> Void in
                self.collectionView?.reloadData()
            })
            print("messages: \(messages)")
            break
        case "message":
            let sender = messages.count % 2 == 1 ? "SimpleChat" : "Empty"
            messages.append(Message(text: json["data"].string!, sender: sender, imageUrl: nil))
            dispatch_async(dispatch_get_main_queue(), {
                () -> Void in
                self.collectionView?.reloadData()
            })
            print("messages: \(messages)")
            break
        default:
            print("message: \(json)")
            break
        }
    }

    func websocketDidReceiveData(socket: WebSocket, data: NSData) {

    }
}

