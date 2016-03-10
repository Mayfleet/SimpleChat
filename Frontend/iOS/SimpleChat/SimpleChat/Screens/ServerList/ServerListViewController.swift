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
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let
        messagesViewController = segue.destinationViewController as? ChatViewController,
        selectedIndexPath = tableView.indexPathForSelectedRow {
            messagesViewController.server = logic.servers[selectedIndexPath.row]

        } else if let logInViewController = segue.destinationViewController as? LogInViewController {
            logInViewController.onClose = {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
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
        return cell
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            logic.removeServerAtIndex(indexPath.row)
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // TODO: Find better solution for segue names
        performSegueWithIdentifier("ShowMessages", sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
