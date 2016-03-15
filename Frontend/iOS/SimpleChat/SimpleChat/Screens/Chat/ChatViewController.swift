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

    var chatLogic: Chat? {
        didSet {
            let center = NSNotificationCenter.defaultCenter()
            if let chatLogic = chatLogic {
                center.addObserverForName(Chat.statusChangedNotification, object: chatLogic, queue: nil, usingBlock: {
                    _ in

                    dispatch_async(dispatch_get_main_queue(), {
                        if let chatLogic = self.chatLogic {
                            switch chatLogic.status {
                            case Chat.Status.Online:
                                self.title = NSLocalizedString("Online", comment: "Online Chat Status")
                                break
                            case Chat.Status.Offline:
                                self.title = NSLocalizedString("Offline", comment: "Offline Chat Status")
                                break
                            }
                        } else {
                            self.title = ""
                        }
                    })
                })

                center.addObserverForName(Chat.messagesChangedNotification, object: chatLogic, queue: nil, usingBlock: {
                    _ in

                    dispatch_async(dispatch_get_main_queue(), {
                        self.collectionView?.reloadData()
                    })
                })

            } else {
                center.removeObserver(self, name: Chat.statusChangedNotification, object: nil)
                center.removeObserver(self, name: Chat.messagesChangedNotification, object: nil)
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        senderId = "iOS App #\(arc4random_uniform(1000) + 1)"
        senderDisplayName = senderId
        inputToolbar?.contentView?.leftBarButtonItemWidth = 0
        inputToolbar?.contentView?.leftContentPadding = 0
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        // TODO: Remove
        chatLogic?.connect()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if let chatLogic = chatLogic where !chatLogic.configuration.autoconnect {
            chatLogic.disconnect()
        }
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData? {
        guard let chatLogic = chatLogic else {
            return nil
        }
        return chatLogic.messages[indexPath.row]
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource? {
        return nil
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource? {
        guard let chatLogic = chatLogic else {
            return nil
        }

        if chatLogic.messages[indexPath.row].senderId() == senderId {
            return JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "AvatarOutgoing"), diameter: 30)
        } else {
            return JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "AvatarIncoming"), diameter: 30)
        }
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        guard let chatLogic = chatLogic else {
            return 0
        }

        if indexPath.row > 0 && chatLogic.messages[indexPath.row].date().mediumDateString == chatLogic.messages[indexPath.row - 1].date().mediumDateString {
            return 0
        }
        return 20
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString? {
        guard let chatLogic = chatLogic else {
            return nil
        }

        return NSAttributedString(string: chatLogic.messages[indexPath.row].date().mediumDateString)
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 20
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString? {
        guard let chatLogic = chatLogic else {
            return nil
        }

        let message = chatLogic.messages[indexPath.row]
        return NSAttributedString(string: "\(message.senderId()) - \(message.date().mediumTimeString)")
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return nil == chatLogic ? 0 : 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let chatLogic = chatLogic else {
            return 0
        }

        print("numberOfItemsInSection: \(chatLogic.messages.count)")
        
        return chatLogic.messages.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell

        if let chatLogic = chatLogic {
            let message = chatLogic.messages[indexPath.item]
            if message.senderId() == senderId {
                cell.textView?.textColor = UIColor(red: 0.16, green: 0.5, blue: 0.73, alpha: 1)
            } else {
                cell.textView?.textColor = UIColor(red: 0.15, green: 0.68, blue: 0.38, alpha: 1)
            }
        }

        return cell
    }

    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        guard let chatLogic = chatLogic else {
            return
        }
        chatLogic.sendText(senderId, text: text)
        finishSendingMessageAnimated(true)
    }
}
