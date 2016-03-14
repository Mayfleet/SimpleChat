//
// Created by Maxim Pervushin on 05/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import UIKit

class ChatConfigurationCell: UITableViewCell {

    static let defaultReuseIdentifier = "ChatConfigurationCell"

    @IBOutlet weak var serverNameLabel: UILabel?
    @IBOutlet weak var serverBackendURLLabel: UILabel?
    @IBOutlet weak var serverNotificationsLabel: UILabel?
    @IBOutlet weak var editorLeadingConstraint: NSLayoutConstraint?

    @IBAction func deleteButtonAction(sender: AnyObject) {
        delegate?.chatConfigurationCellDidDelete(self)
    }
    
    @IBAction func autoconnectButtonAction(sender: AnyObject) {
        delegate?.chatConfigurationCellDidToggleAutoconnect(self)
    }
    
    weak var delegate: ChatConfigurationCellDelegate?
    
    var chatConfiguration: ChatConfiguration? {
        didSet {
            serverNameLabel?.text = chatConfiguration?.name
            serverBackendURLLabel?.text = chatConfiguration?.backendURL.absoluteString
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
            UIView.animateWithDuration(0.5, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 1, options: [.CurveEaseInOut], animations: { () -> Void in
                self.layoutIfNeeded()
                }, completion: nil)
        }
    }
}

protocol ChatConfigurationCellDelegate: class {
    
    func chatConfigurationCellDidDelete(cell: ChatConfigurationCell)
    
    func chatConfigurationCellDidToggleAutoconnect(cell: ChatConfigurationCell)
}