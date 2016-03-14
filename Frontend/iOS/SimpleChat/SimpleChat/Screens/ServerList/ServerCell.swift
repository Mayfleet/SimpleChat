//
// Created by Maxim Pervushin on 05/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import UIKit

class ServerCell: UITableViewCell {

    static let defaultReuseIdentifier = "ServerCell"

    @IBOutlet weak var serverNameLabel: UILabel?
    @IBOutlet weak var serverBackendURLLabel: UILabel?

    var server: ServerConfiguration? {
        didSet {
            serverNameLabel?.text = server?.name
            serverBackendURLLabel?.text = server?.backendURL.absoluteString
        }
    }
}
