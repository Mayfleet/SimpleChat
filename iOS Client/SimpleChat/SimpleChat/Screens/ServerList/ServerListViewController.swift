//
// Created by Maxim Pervushin on 05/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import UIKit

class ServerListViewController: UITableViewController {

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
            if self.dataSource.addServerWithName(serverName, backendURLString: serverBackendURLString) {
                let newIndexPath = NSIndexPath(forRow: self.dataSource.servers.count - 1, inSection: 0)
                self.tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Automatic)
            }
        }))

        self.presentViewController(alert, animated: true, completion: nil)
    }

    let dataSource = ServerListDataSource()

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource.onChange = dataChanged
    }

    private func dataChanged() {
        dispatch_async(dispatch_get_main_queue(), {
            self.tableView?.reloadData()
        })
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let
        messagesViewController = segue.destinationViewController as? MessagesViewController,
        selectedIndexPath = tableView.indexPathForSelectedRow {
            messagesViewController.server = dataSource.servers[selectedIndexPath.row]
        }
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.servers.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ServerCell.defaultReuseIdentifier, forIndexPath: indexPath) as! ServerCell
        cell.server = dataSource.servers[indexPath.row]
        return cell
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            dataSource.removeServerAtIndex(indexPath.row)
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // TODO: Find better solution for segue names
        performSegueWithIdentifier("ShowMessages", sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
