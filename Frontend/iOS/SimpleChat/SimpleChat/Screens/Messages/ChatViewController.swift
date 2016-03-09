//
//  ChatViewController.swift
//  SimpleChat
//
//  Created by Maxim Pervushin on 01/03/16.
//  Copyright © 2016 Maxim Pervushin. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {

    // MARK: - ChatViewController

    var server: Server? {
        set {
            logic.server = newValue
        }
        get {
            return logic.server
        }
    }

    private let logic = ChatLogic()

    override func viewDidLoad() {
        super.viewDidLoad()
        senderId = "iOS App #\(arc4random_uniform(1000) + 1)"
        senderDisplayName = senderId
        inputToolbar?.contentView?.leftBarButtonItemWidth = 0
        inputToolbar?.contentView?.leftContentPadding = 0
        logic.onChange = {
            dispatch_async(dispatch_get_main_queue(), {
                self.collectionView?.reloadData()
            })
        }
        logic.onStatusChange = {
            status in
            dispatch_async(dispatch_get_main_queue(), {
                if let server = self.server {
                    self.title = "\(server.name) (\(status))"
                } else {
                    self.title = ""
                }
            })
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        logic.connect()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        logic.disconnect()
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return logic.messages[indexPath.row]
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        if logic.messages[indexPath.row].senderId() == senderId {
            return JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor().colorWithAlphaComponent(0.5))
        } else {
            return JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor.blueColor().colorWithAlphaComponent(0.5))
        }
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource? {
        if logic.messages[indexPath.row].senderId() == senderId {
            return JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "AvatarOutgoing"), diameter: 30)
        } else {
            return JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "AvatarIncoming"), diameter: 30)
        }
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        if indexPath.row > 0 && logic.messages[indexPath.row].date().mediumDateString == logic.messages[indexPath.row - 1].date().mediumDateString {
            return 0
        }
        return 20
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString? {
        return NSAttributedString(string: logic.messages[indexPath.row].date().mediumDateString)
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 20
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        let message = logic.messages[indexPath.row]
        return NSAttributedString(string: "\(message.senderId()) - \(message.date().mediumTimeString)")
    }

    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return logic.messages.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell

        let message = logic.messages[indexPath.item]
        if message.senderId() == senderId {
            cell.textView?.textColor = UIColor.blackColor()
        } else {
            cell.textView?.textColor = UIColor.whiteColor()
        }

        return cell
    }

    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        logic.sendText(senderId, text: text)
        finishSendingMessageAnimated(true)
    }
}
