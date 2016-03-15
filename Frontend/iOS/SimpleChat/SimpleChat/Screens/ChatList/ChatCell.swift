//
// Created by Maxim Pervushin on 05/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import UIKit

class ChatCell: UITableViewCell {

    static let defaultReuseIdentifier = "ChatCell"

    @IBOutlet weak var serverNameLabel: UILabel?
    @IBOutlet weak var serverNameEditingLabel: UILabel?
    @IBOutlet weak var serverBackendURLLabel: UILabel?
    @IBOutlet weak var serverNotificationsLabel: UILabel?
    @IBOutlet weak var editorLeadingConstraint: NSLayoutConstraint?
    @IBOutlet weak var autoconnectButton: UIButton?

    @IBAction func autoconnectButtonAction(sender: AnyObject) {
        delegate?.chatConfigurationCellDidToggleAutoconnect(self)
    }

    @IBAction func editButtonAction(sender: AnyObject) {
//        delegate?.chatConfigurationCellDidDelete(self)
    }

    @IBAction func deleteButtonAction(sender: AnyObject) {
        delegate?.chatConfigurationCellDidDelete(self)
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

    weak var delegate: ChatConfigurationCellDelegate?

    var chat: Chat? {
        didSet {
            serverNameLabel?.text = chat?.configuration.name
            serverNameEditingLabel?.text = chat?.configuration.name
            serverBackendURLLabel?.text = chat?.configuration.backendURL.absoluteString

            var autoconnectTitle = NSLocalizedString("Autoconnect: Off", comment: "Autoconnect Button Title: Off")
            var autoconnectTextColor = UIColor(hue: 0.07, saturation: 1, brightness: 0.83, alpha: 1)
            if let configuration = chat?.configuration where configuration.autoconnect {
                autoconnectTitle = NSLocalizedString("Autoconnect: On", comment: "Autoconnect Button Title: On")
                autoconnectTextColor = UIColor(hue: 0.47, saturation: 0.82, brightness: 0.63, alpha: 1)
            }
            var autoconnectBackgroundColor = autoconnectTextColor.colorWithAlphaComponent(0.25)
            autoconnectButton?.setTitle(autoconnectTitle, forState: .Normal)
            autoconnectButton?.setTitleColor(autoconnectTextColor, forState: .Normal)
            autoconnectButton?.backgroundColor = autoconnectBackgroundColor
        }
    }

    var notificationsCount = 0 {
        didSet {
            if notificationsCount > 0 {
                serverNotificationsLabel?.hidden = false
                serverNotificationsLabel?.text = "\(notificationsCount)"
            } else {
                serverNotificationsLabel?.hidden = true
            }
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


}

protocol ChatConfigurationCellDelegate: class {

    func chatConfigurationCellDidDelete(cell: ChatCell)

    func chatConfigurationCellDidToggleAutoconnect(cell: ChatCell)
}