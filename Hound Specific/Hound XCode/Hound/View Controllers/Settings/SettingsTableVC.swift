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

    // 6 pages and 2 space cells to allow for proper edge insets
    private let numberOfPages = (6 + 1 + 1)

    weak var delegate: SettingsTableViewControllerDelegate! = nil

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorColor = .white
        // make seperator go the whole distance, then individual cells can change it.
        tableView.separatorInset = UIEdgeInsets.zero
    }

    // MARK: - Table View Data Source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return numberOfPages
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell?

        let iconEdgeInset = UIEdgeInsets.init(top: 0, left: (5.0+35.5+2.5), bottom: 0, right: 0)
        switch indexPath.row {
        case 0:
            cell = tableView.dequeueReusableCell(withIdentifier: "spaceWithoutSeparator", for: indexPath)
            cell!.separatorInset = UIEdgeInsets.zero
        case 1:
            cell = tableView.dequeueReusableCell(withIdentifier: "personalInformation", for: indexPath)
            cell!.separatorInset = iconEdgeInset
        case 2:
            cell = tableView.dequeueReusableCell(withIdentifier: "family", for: indexPath)
            cell!.separatorInset = iconEdgeInset
        case 3:
            cell = tableView.dequeueReusableCell(withIdentifier: "appearance", for: indexPath)
            cell!.separatorInset = iconEdgeInset
        case 4:
            cell = tableView.dequeueReusableCell(withIdentifier: "reminders", for: indexPath)
            cell!.separatorInset = iconEdgeInset
        case 5:
            cell = tableView.dequeueReusableCell(withIdentifier: "notifications", for: indexPath)
            cell!.separatorInset = UIEdgeInsets.zero
        case 6:
            cell = tableView.dequeueReusableCell(withIdentifier: "spaceWithSeparator", for: indexPath)
            cell!.separatorInset = UIEdgeInsets.zero
        case 7:
            cell = tableView.dequeueReusableCell(withIdentifier: "about", for: indexPath)
            cell!.separatorInset = UIEdgeInsets.zero
        default:
            // fall through
            cell = tableView.dequeueReusableCell(withIdentifier: "about", for: indexPath)
            cell!.separatorInset = UIEdgeInsets.zero
        }
        cell!.selectionStyle = .blue
        return cell!
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // cannot select the space cells so no need to worry about them
        self.tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        // cell identifer converted into segue version in settings vc
        delegate.willPerformSegue(withIdentifier: cell!.reuseIdentifier!)
    }
}
