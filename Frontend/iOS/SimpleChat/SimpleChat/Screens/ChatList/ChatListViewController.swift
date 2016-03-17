//
// Created by Maxim Pervushin on 05/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import UIKit
import ChameleonFramework

class ChatListViewController: UITableViewController {

    // MARK: - ChatListViewController @IB

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

            if App.chatDispatcher.addChat(Chat(name: name, backendURLString: backendURLString)) {
                let newIndexPath = NSIndexPath(forRow: App.chatDispatcher.chats.count - 1, inSection: 0)
                self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
            }
        }))

        self.presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: - ChatListViewController

    private func dataChanged() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView?.reloadData()
        })
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let
        chatViewController = segue.destinationViewController as? ChatViewController,
        selectedIndexPath = tableView.indexPathForSelectedRow {
            chatViewController.chat = App.chatDispatcher.chats[selectedIndexPath.row]
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
            return tableView.dequeueReusableCellWithIdentifier(AddChatCell.defaultReuseIdentifier, forIndexPath: indexPath)
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            performSegueWithIdentifier(App.SegueIdentifiers.showChat, sender: self)
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
}

extension ChatListViewController: ChatCellDelegate {

    func chatCellDidDelete(cell: ChatCell) {
        if let chat = cell.chat {
            if App.chatDispatcher.removeChat(chat) {
                tableView?.reloadData()
            }
        }
    }

    func chatCellDidEdit(cell: ChatCell) {
        // TODO: Implement
        print("edit: \(cell.chat)")
    }

    func chatCellDidToggleAutoconnect(cell: ChatCell) {
        if let chat = cell.chat {
            chat.autoconnect = !chat.autoconnect
            if App.chatDispatcher.updateChat(chat) {
                tableView?.reloadData()
            }
        }
    }
}
