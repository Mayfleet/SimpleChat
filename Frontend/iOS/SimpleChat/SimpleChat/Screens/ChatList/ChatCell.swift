//
// Created by Maxim Pervushin on 05/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import UIKit


protocol ChatCellDelegate: class {

    func chatCellDidDelete(cell: ChatCell)

    func chatCellDidEdit(cell: ChatCell)

    func chatCellDidToggleAutoconnect(cell: ChatCell)
}

class ChatCell: UITableViewCell {

    static let defaultReuseIdentifier = "ChatCell"

    @IBOutlet weak var serverNameLabel: UILabel?
    @IBOutlet weak var serverNameEditingLabel: UILabel?
    @IBOutlet weak var serverBackendURLLabel: UILabel?
    @IBOutlet weak var serverNotificationsLabel: UILabel?
    @IBOutlet weak var editorLeadingConstraint: NSLayoutConstraint?
    @IBOutlet weak var autoconnectButton: UIButton?

    @IBAction func autoconnectButtonAction(sender: AnyObject) {
        delegate?.chatCellDidToggleAutoconnect(self)
    }

    @IBAction func editButtonAction(sender: AnyObject) {
        delegate?.chatCellDidEdit(self)
    }

    @IBAction func deleteButtonAction(sender: AnyObject) {
        delegate?.chatCellDidDelete(self)
    }

    @objc func swipeLeftAction(sender: AnyObject) {
        if !editing {
            setEditing(true, animated: true)
        }
    }

    @objc func swipeRightAction(sender: AnyObject) {
        if editing {
            setEditing(false, animated: true)
        }
    }

    weak var delegate: ChatCellDelegate?

    var chat: Chat? {
        didSet {
            serverNameLabel?.text = chat?.name
            serverNameEditingLabel?.text = chat?.name
            serverBackendURLLabel?.text = chat?.backendURL.absoluteString

            var autoconnectTitle = NSLocalizedString("Autoconnect: Off", comment: "Autoconnect Button Title: Off")
            var autoconnectTextColor = UIColor(hue: 0.07, saturation: 1, brightness: 0.83, alpha: 1)
            if let chat = chat where chat.autoconnect {
                autoconnectTitle = NSLocalizedString("Autoconnect: On", comment: "Autoconnect Button Title: On")
                autoconnectTextColor = UIColor(hue: 0.47, saturation: 0.82, brightness: 0.63, alpha: 1)
            }
            var autoconnectBackgroundColor = autoconnectTextColor.colorWithAlphaComponent(0.25)
            autoconnectButton?.setTitle(autoconnectTitle, forState: .Normal)
            autoconnectButton?.setTitleColor(autoconnectTextColor, forState: .Normal)
            autoconnectButton?.backgroundColor = autoconnectBackgroundColor

            subscribe()
        }
    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        if let editorToLeftConstraint = editorLeadingConstraint {
            layoutIfNeeded()
            let width = frame.size.width
            editorToLeftConstraint.constant = editing ? 0 : width
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [.CurveEaseInOut], animations: {
                () -> Void in
                self.layoutIfNeeded()
            }, completion: nil)
        }
    }

    private func subscribe() {
        unsubscribe()
        if let chat = chat {
            let center = NSNotificationCenter.defaultCenter()
            center.addObserverForName(Chat.statusChangedNotification, object: chat, queue: nil, usingBlock: chatStatusChangedNotification)
            center.addObserverForName(Chat.messagesChangedNotification, object: chat, queue: nil, usingBlock: chatMessagesChangedNotification)
        }
        updateUI()
    }

    private func unsubscribe() {
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(self, name: Chat.statusChangedNotification, object: nil)
        center.removeObserver(self, name: Chat.messagesChangedNotification, object: nil)
    }

    private func updateUI() {
        guard let chat = chat else {
            serverNotificationsLabel?.hidden = true
            return
        }

        serverNotificationsLabel?.hidden = false
        serverNotificationsLabel?.text = chat.messages.count > 0 ? "\(chat.messages.count)" : ""

        switch chat.status {
        case Chat.Status.Online:
            serverNotificationsLabel?.textColor = UIColor(red: 0.15, green: 0.69, blue: 0.37, alpha: 1)
            serverNotificationsLabel?.backgroundColor = UIColor(red: 0.15, green: 0.69, blue: 0.37, alpha: 0.25)
            break
        case Chat.Status.Offline:
            serverNotificationsLabel?.textColor = UIColor(red: 0.75, green: 0.22, blue: 0.17, alpha: 1)
            serverNotificationsLabel?.backgroundColor = UIColor(red: 0.75, green: 0.22, blue: 0.17, alpha: 0.25)
            break
        }
    }

    private func commonInit() {
        let leftSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeLeftAction:")
        leftSwipeRecognizer.numberOfTouchesRequired = 1
        leftSwipeRecognizer.direction = .Left
        addGestureRecognizer(leftSwipeRecognizer)

        let rightSwipeRecognizer = UISwipeGestureRecognizer(target: self, action: "swipeRightAction:")
        rightSwipeRecognizer.numberOfTouchesRequired = 1
        rightSwipeRecognizer.direction = .Right
        addGestureRecognizer(rightSwipeRecognizer)
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    deinit {
        unsubscribe()
    }
}

extension ChatCell {

    private func chatStatusChangedNotification(notification: NSNotification) {
        updateUI()
    }

    private func chatMessagesChangedNotification(notification: NSNotification) {
        updateUI()
    }
}