//
// Created by Maxim Pervushin on 21/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import UIKit

class ChatController: UITabBarController {

    // MARK: ChatController

    var chat: Chat? {
        didSet {
            let center = NSNotificationCenter.defaultCenter()
            if let chat = chat {
                center.addObserverForName(Chat.authenticationChangedNotification, object: chat, queue: nil, usingBlock: chatAuthenticationChangedNotification)
                center.addObserverForName(Chat.statusChangedNotification, object: chat, queue: nil, usingBlock: chatStatusChangedNotification)
                center.addObserverForName(Chat.messagesChangedNotification, object: chat, queue: nil, usingBlock: chatMessagesChangedNotification)

            } else {
                center.removeObserver(self, name: Chat.authenticationChangedNotification, object: nil)
                center.removeObserver(self, name: Chat.statusChangedNotification, object: nil)
                center.removeObserver(self, name: Chat.messagesChangedNotification, object: nil)
            }

            dispatch_async(dispatch_get_main_queue(), {
                self.title = self.chat?.name
            })

            chatViewController?.chat = chat
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar.hidden = true
        chatViewController?.chat = chat
        logInViewController?.didLogIn = {
            (username: String?, password: String?) in
            self.chat?.sendSignIn(SigninRequest(username: username, password: password))
        }
        logInViewController?.signUpButtonAction = {
            self.selectedViewController = self.signUpViewController
        }
        signUpViewController?.didSignUp = {
            (username: String?, password: String?) in
            self.chat?.sendSignUp(SignupRequest(username: username, password: password))
        }
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        chat?.connect()
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if let chat = chat where !chat.autoconnect {
            chat.disconnect()
        }
    }


    private var chatViewController: ChatViewController? {
        if let viewControllers = viewControllers {
            for case let viewController as ChatViewController in viewControllers {
                return viewController
            }
        }
        return nil
    }

    private var logInViewController: LogInViewController? {
        if let viewControllers = viewControllers {
            for case let viewController as LogInViewController in viewControllers {
                return viewController
            }
        }
        return nil
    }

    private var signUpViewController: SignUpViewController? {
        if let viewControllers = viewControllers {
            for case let viewController as SignUpViewController in viewControllers {
                return viewController
            }
        }
        return nil
    }

    // MARK: Chat notifications

    private func chatAuthenticationChangedNotification(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), {
            if let chat = self.chat where chat.authenticationRequired {
                self.selectedViewController = self.logInViewController
            } else {
                self.selectedViewController = self.chatViewController
            }
        })
    }

    private func chatStatusChangedNotification(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), {
            if let chat = self.chat {
                switch chat.status {
                case Chat.Status.Online:
                    self.navigationItem.prompt = NSLocalizedString("Online", comment: "Online Chat Status")
                    break
                case Chat.Status.Offline:
                    self.navigationItem.prompt = NSLocalizedString("Offline", comment: "Offline Chat Status")
                    break
                }
            } else {
                self.title = ""
            }
        })
    }

    private func chatMessagesChangedNotification(notification: NSNotification) {
        dispatch_async(dispatch_get_main_queue(), {
            self.chatViewController?.collectionView?.reloadData()
        })
    }
}
