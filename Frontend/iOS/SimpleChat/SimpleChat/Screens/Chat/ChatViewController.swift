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

    var chat: Chat? {
        didSet {
            let center = NSNotificationCenter.defaultCenter()
            if let chat = chat {
                center.addObserverForName(Chat.statusChangedNotification, object: chat, queue: nil, usingBlock: {
                    _ in

                    dispatch_async(dispatch_get_main_queue(), {
                        if let chat = self.chat {
                            switch chat.status {
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

                center.addObserverForName(Chat.messagesChangedNotification, object: chat, queue: nil, usingBlock: {
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
        chat?.connect()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if let chat = chat where !chat.autoconnect {
            chat.disconnect()
        }
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData? {
        guard let chat = chat else {
            return nil
        }
        return chat.messages[indexPath.row]
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource? {
        return nil
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource? {
        guard let chat = chat else {
            return nil
        }

        if chat.messages[indexPath.row].senderId() == senderId {
            return JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "AvatarOutgoing"), diameter: 30)
        } else {
            return JSQMessagesAvatarImageFactory.avatarImageWithImage(UIImage(named: "AvatarIncoming"), diameter: 30)
        }
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        guard let chat = chat else {
            return 0
        }

        if indexPath.row > 0 && chat.messages[indexPath.row].date().mediumDateString == chat.messages[indexPath.row - 1].date().mediumDateString {
            return 0
        }
        return 20
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString? {
        guard let chat = chat else {
            return nil
        }

        return NSAttributedString(string: chat.messages[indexPath.row].date().mediumDateString)
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        return 20
    }

    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString? {
        guard let chat = chat else {
            return nil
        }

        let message = chat.messages[indexPath.row]
        return NSAttributedString(string: "\(message.senderId()) - \(message.date().mediumTimeString)")
    }

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return nil == chat ? 0 : 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let chat = chat else {
            return 0
        }

        print("numberOfItemsInSection: \(chat.messages.count)")
        
        return chat.messages.count
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath) as! JSQMessagesCollectionViewCell

        if let chat = chat {
            let message = chat.messages[indexPath.item]
            if message.senderId() == senderId {
                cell.textView?.textColor = UIColor(red: 0.16, green: 0.5, blue: 0.73, alpha: 1)
            } else {
                cell.textView?.textColor = UIColor(red: 0.15, green: 0.68, blue: 0.38, alpha: 1)
            }
        }

        return cell
    }

    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        guard let chat = chat else {
            return
        }
        chat.sendText(senderId, text: text)
        finishSendingMessageAnimated(true)
    }
}
