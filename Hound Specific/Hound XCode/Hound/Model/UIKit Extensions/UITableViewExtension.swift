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
        if indexPathsForSelectedRows != nil {
            for indexPath in self.indexPathsForSelectedRows! {
                self.deselectRow(at: indexPath, animated: false)
            }
        }
    }
}
