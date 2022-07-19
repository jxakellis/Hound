//
//  UITableViewExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/30/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

extension UITableView {
    /// Deselects all rows
    func deselectAll() {
        indexPathsForSelectedRows?.forEach({ indexPath in
            self.deselectRow(at: indexPath, animated: false)
        })
    }
}
