//
// Created by Maxim Pervushin on 05/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import UIKit

class ServerListViewController: UITableViewController {

    // MARK: - ServerListViewController @IB

    @IBAction func addServerButtonAction(sender: AnyObject) {
        let alert = UIAlertController(title: "Add Server", message: nil, preferredStyle: .Alert)

        alert.addTextFieldWithConfigurationHandler({
            textField in
            textField.placeholder = "Name"
        })

        alert.addTextFieldWithConfigurationHandler({
            textField in
            textField.placeholder = "Backend URL"
        })

        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        alert.addAction(UIAlertAction(title: "Add", style: .Default, handler: {
            _ in

            let name = alert.textFields?[0].text
            let backendURLString = alert.textFields?[1].text

            if App.chatDispatcher.addChat(Chat(configuration: ChatConfiguration(name: name, backendURLString: backendURLString))) {
                let newIndexPath = NSIndexPath(forRow: App.chatDispatcher.chats.count - 1, inSection: 0)
                self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
            }
        }))

        self.presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: - ServerListViewController

    private func dataChanged() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView?.reloadData()
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: Find better place to subscribe
        subscribe()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let
        chatViewController = segue.destinationViewController as? ChatViewController,
        selectedIndexPath = tableView.indexPathForSelectedRow {
            chatViewController.chatLogic = App.chatDispatcher.chats[selectedIndexPath.row]
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? App.chatDispatcher.chats.count : 1
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(ChatCell.defaultReuseIdentifier, forIndexPath: indexPath) as! ChatCell
            cell.chat = App.chatDispatcher.chats[indexPath.row]
            cell.delegate = self
            return cell
        } else {
            return tableView.dequeueReusableCellWithIdentifier("AddChatCell", forIndexPath: indexPath)
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // TODO: Find better solution for segue names
        if indexPath.section == 0 {
            performSegueWithIdentifier("ShowMessages", sender: self)
        } else {
            addServerButtonAction(self)
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if indexPath.section == 1 {
            return indexPath
        } else {
            if let cell = tableView.cellForRowAtIndexPath(indexPath) where /*!editing && */ !cell.editing {
                return indexPath
            } else {
                return nil
            }
        }
    }

    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .None
    }

    override func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return false
    }

    private func subscribe() {
        let center = NSNotificationCenter.defaultCenter()
        center.addObserverForName(Chat.statusChangedNotification, object: nil, queue: nil, usingBlock: chatStatusChangedNotification)
        center.addObserverForName(Chat.messagesChangedNotification, object: nil, queue: nil, usingBlock: chatMessagesChangedNotification)
    }

    private func unsubscribe() {
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(self, name: Chat.statusChangedNotification, object: nil)
        center.removeObserver(self, name: Chat.messagesChangedNotification, object: nil)
    }

    // Chat Notifications

    private func chatStatusChangedNotification(notification: NSNotification) {
        // TODO: Display status in cell
    }

    private func chatMessagesChangedNotification(notification: NSNotification) {
        if let chat = notification.object as? Chat {
            for case let cell as ChatCell in tableView.visibleCells where cell.chat == chat {
                dispatch_async(dispatch_get_main_queue(), {
                    cell.notificationsCount = chat.messages.count
                })
            }
        }
    }
}

extension ServerListViewController: ChatConfigurationCellDelegate {

    func chatConfigurationCellDidDelete(cell: ChatCell) {
        if let chat = cell.chat {
            if App.chatDispatcher.removeChat(chat) {
                tableView?.reloadData()
            }
        }
    }

    func chatConfigurationCellDidToggleAutoconnect(cell: ChatCell) {
        if let chat = cell.chat {
            chat.configuration.autoconnect = !chat.configuration.autoconnect
            if App.chatDispatcher.updateChat(chat) {
                tableView?.reloadData()
            }
        }
    }
}
