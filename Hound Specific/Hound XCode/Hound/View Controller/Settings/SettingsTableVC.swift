//
//  SettingsTableViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/16/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol SettingsTableViewControllerDelegate: AnyObject {
    func willPerformSegue(withIdentifier: String)
}

class SettingsTableViewController: UITableViewController {

    // MARK: - Properties

    let numberOfPages = 6

    weak var delegate: SettingsTableViewControllerDelegate! = nil

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .white
        // make the seperator end in between the icon and the name
        tableView.separatorInset = UIEdgeInsets.init(top: 0, left: (5.0+35.5+2.5), bottom: 0, right: 0)
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return numberOfPages
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell?

        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "personalInformation", for: indexPath)
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "family", for: indexPath)
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "appearance", for: indexPath)
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "reminders", for: indexPath)
        case 4:
            cell = tableView.dequeueReusableCell(withIdentifier: "notifications", for: indexPath)
        case 5:
            cell = tableView.dequeueReusableCell(withIdentifier: "about", for: indexPath)
        default:
            // fall through
            cell = tableView.dequeueReusableCell(withIdentifier: "about", for: indexPath)
        }
        cell!.selectionStyle = .blue
        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        // cell identifier should be the same as the segue identifer
        delegate.willPerformSegue(withIdentifier: cell!.reuseIdentifier!)
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // make spacing between cells
        let headerView = UIView()
        headerView.backgroundColor = view.backgroundColor
        return headerView
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        
        // Tried to select the copyright cell. Don't allow selection of that one
        let cell = tableView.cellForRow(at: indexPath)
        
        if cell!.reuseIdentifier == "copyright" {
            return false
        }
        else {
            return true
        }
        
    }
     */

}
