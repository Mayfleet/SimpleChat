//
//  MessagesViewController.swift
//  SimpleChat
//
//  Created by Maxim Pervushin on 01/03/16.
//  Copyright © 2016 Maxim Pervushin. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class MessagesViewController: JSQMessagesViewController {

    let dataSource = MessagesDataSource()

    public var server: Server? {
        set {
            dataSource.server = newValue
        }
        get {
            return dataSource.server
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        senderId = "iOS App"
        senderDisplayName = "iOS App"
        dataSource.onChange = {
            dispatch_async(dispatch_get_main_queue(), {
                self.collectionView?.reloadData()
            })
        }
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return dataSource.messages[indexPath.row]
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        if dataSource.messages[indexPath.row].senderId() == senderId {
            return JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor().colorWithAlphaComponent(0.5))
        } else {
            return JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.blueColor().colorWithAlphaComponent(0.5))
        }
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        if dataSource.messages[indexPath.row].senderId() == senderId {
            return JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "AvatarOutgoing"), diameter: 30)
        } else {
            return JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "AvatarIncoming"), diameter: 30)
        }
    }

//    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString? {
//        let message = dataSource.messages[indexPath.row]
//        return NSAttributedString(string: message.senderId())
//    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = dataSource.messages[indexPath.row]
        return NSAttributedString(string: message.senderId())
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataSource.messages.count
    }

//    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
//        return 20
//    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 20
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell

        let message = dataSource.messages[indexPath.item]
        if message.senderId() == senderId {
            cell.textView?.textColor = UIColor.blackColor()
        } else {
            cell.textView?.textColor = UIColor.whiteColor()
        }

        return cell
    }

    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        dataSource.sendText(senderId, text: text)
    }
}
