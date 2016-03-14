//
// Created by Maxim Pervushin on 05/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import UIKit

class ServerCell: UITableViewCell {

    static let defaultReuseIdentifier = "ServerCell"

    @IBOutlet weak var serverNameLabel: UILabel?
    @IBOutlet weak var serverBackendURLLabel: UILabel?
    @IBOutlet weak var serverNotificationsLabel: UILabel?
    @IBOutlet weak var editorLeadingConstraint: NSLayoutConstraint?

    @IBAction func deleteButtonAction(sender: AnyObject) {
        delegate?.serverCellDidDelete(self)
    }
    
    @IBAction func autoconnectButtonAction(sender: AnyObject) {
        delegate?.serverCellDidToggleAutoconnect(self)
    }
    
    weak var delegate: ServerCellDelegate?
    
    var server: ServerConfiguration? {
        didSet {
            serverNameLabel?.text = server?.name
            serverBackendURLLabel?.text = server?.backendURL.absoluteString
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

protocol ServerCellDelegate: class {
    
    func serverCellDidDelete(serverCell: ServerCell)
    
    func serverCellDidToggleAutoconnect(serverCell: ServerCell)
}