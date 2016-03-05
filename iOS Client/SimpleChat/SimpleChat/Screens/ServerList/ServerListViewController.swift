//
// Created by Maxim Pervushin on 05/03/16.
// Copyright (c) 2016 Maxim Pervushin. All rights reserved.
//

import UIKit

class ServerListViewController: UITableViewController {

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

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // TODO: Find better solution for segue names
        performSegueWithIdentifier("ShowMessages", sender: self)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}
