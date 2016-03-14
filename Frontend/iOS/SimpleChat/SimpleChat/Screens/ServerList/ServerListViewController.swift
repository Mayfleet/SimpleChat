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

            let serverName = alert.textFields?[0].text
            let serverBackendURLString = alert.textFields?[1].text
            if self.logic.addServerWithName(serverName, backendURLString: serverBackendURLString) {
                let newIndexPath = NSIndexPath(forRow: self.logic.servers.count - 1, inSection: 0)
                self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
            }
        }))

        self.presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: - ServerListViewController

    private let logic = ServerListLogic()

    private func dataChanged() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView?.reloadData()
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        logic.onChange = dataChanged

        
        navigationItem.leftBarButtonItem = editButtonItem()
        
//        if let toggleEditButton = toggleEditButton {
//            editButtonItem()
//        }
        
        // TODO: Find better place to subscribe
        subscribe()
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let
        chatViewController = segue.destinationViewController as? ChatViewController,
        selectedIndexPath = tableView.indexPathForSelectedRow {
            chatViewController.chatLogic = ChatDispatcher.defaultDispatcher.chatWithConfiguration(logic.servers[selectedIndexPath.row])
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return logic.servers.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ServerCell.defaultReuseIdentifier, forIndexPath: indexPath) as! ServerCell
        cell.server = logic.servers[indexPath.row]
        cell.delegate = self
        return cell
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            logic.removeServerAtIndex(indexPath.row)
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // TODO: Find better solution for segue names
//        performSegueWithIdentifier("ShowMessages", sender: self)
//        tableView.deselectRowAtIndexPath(indexPath, animated: true)

        ChatDispatcher.defaultDispatcher.connectChatWithConfiguration(logic.servers[indexPath.row])
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
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
            for case let cell as ServerCell in tableView.visibleCells {
                if cell.server == chat.configuration {
                    dispatch_async(dispatch_get_main_queue(), {
                        cell.notificationsCount = chat.messages.count
                    })
                }
            }
        }
    }
}

extension ServerListViewController: ServerCellDelegate {

    func serverCellDidDelete(serverCell: ServerCell) {
        print("Delete")
    }

    func serverCellDidToggleAutoconnect(serverCell: ServerCell) {
        print("Toggle Autoconnect")
    }
}
