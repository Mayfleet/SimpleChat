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

            if ChatDispatcher.defaultDispatcher.addChat(ChatLogic(configuration: ChatConfiguration(name: name, backendURLString: backendURLString))) {
                let newIndexPath = NSIndexPath(forRow: ChatDispatcher.defaultDispatcher.chats.count - 1, inSection: 0)
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
        navigationItem.leftBarButtonItem = editButtonItem()

        // TODO: Find better place to subscribe
        subscribe()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let
        chatViewController = segue.destinationViewController as? ChatViewController,
        selectedIndexPath = tableView.indexPathForSelectedRow {
            chatViewController.chatLogic = ChatDispatcher.defaultDispatcher.chats[selectedIndexPath.row]
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ChatDispatcher.defaultDispatcher.chats.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ChatConfigurationCell.defaultReuseIdentifier, forIndexPath: indexPath) as! ChatConfigurationCell
        cell.chat = ChatDispatcher.defaultDispatcher.chats[indexPath.row]
        cell.delegate = self
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // TODO: Find better solution for segue names
        performSegueWithIdentifier("ShowMessages", sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) where !editing && !cell.editing {
            return indexPath
        } else {
            return nil
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
        center.addObserverForName(ChatLogic.statusChangedNotification, object: nil, queue: nil, usingBlock: chatStatusChangedNotification)
        center.addObserverForName(ChatLogic.messagesChangedNotification, object: nil, queue: nil, usingBlock: chatMessagesChangedNotification)
    }

    private func unsubscribe() {
        let center = NSNotificationCenter.defaultCenter()
        center.removeObserver(self, name: ChatLogic.statusChangedNotification, object: nil)
        center.removeObserver(self, name: ChatLogic.messagesChangedNotification, object: nil)
    }

    // Chat Notifications

    private func chatStatusChangedNotification(notification: NSNotification) {

    }

    private func chatMessagesChangedNotification(notification: NSNotification) {
        if let chat = notification.object as? ChatLogic {
            for case let cell as ChatConfigurationCell in tableView.visibleCells {
                if cell.chat == chat {
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.notificationsCount = chat.messages.count
                    })
                }
            }
        }
    }
}

extension ServerListViewController: ChatConfigurationCellDelegate {

    func chatConfigurationCellDidDelete(cell: ChatConfigurationCell) {
        if let chat = cell.chat {
            if ChatDispatcher.defaultDispatcher.removeChat(chat) {
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadData()
                })
            }
        }
    }

    func chatConfigurationCellDidToggleAutoconnect(cell: ChatConfigurationCell) {
        print("Toggle Autoconnect")
    }
}
