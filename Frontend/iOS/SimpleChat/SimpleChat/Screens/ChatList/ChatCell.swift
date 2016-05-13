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
    @IBOutlet weak var serverNotificationsLabel: UILabel?
    @IBOutlet weak var leadingConstraint: NSLayoutConstraint?
    @IBOutlet weak var editorContainer: UIView?
    @IBOutlet weak var autoconnectButton: UIButton?
    @IBOutlet weak var editButton: UIButton?
    @IBOutlet weak var deleteButton: UIButton?

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

            var autoconnectTitle = NSLocalizedString("Autoconnect: Off", comment: "Autoconnect Button Title: Off")
            var autoconnectBackgroundColor = UIColor.flatYellowColorDark()

            if let chat = chat where chat.autoconnect {
                autoconnectTitle = NSLocalizedString("Autoconnect: On", comment: "Autoconnect Button Title: On")
                autoconnectBackgroundColor = UIColor.flatGreenColorDark()
            }
            autoconnectButton?.setTitle(autoconnectTitle, forState: .Normal)
            autoconnectButton?.backgroundColor = autoconnectBackgroundColor

            subscribe()
        }
    }

    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        if let
        leadingConstraint = leadingConstraint,
        editorContainer = editorContainer {

            layoutIfNeeded()
            leadingConstraint.constant = editing ? -editorContainer.frame.size.width : 4
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
            serverNotificationsLabel?.backgroundColor = UIColor.flatGreenColorDark()
            break
        case Chat.Status.Offline:
            serverNotificationsLabel?.backgroundColor = UIColor.flatRedColorDark()
            break
        }

        editButton?.backgroundColor = UIColor.flatSkyBlueColorDark()
        deleteButton?.backgroundColor = UIColor.flatRedColorDark()
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