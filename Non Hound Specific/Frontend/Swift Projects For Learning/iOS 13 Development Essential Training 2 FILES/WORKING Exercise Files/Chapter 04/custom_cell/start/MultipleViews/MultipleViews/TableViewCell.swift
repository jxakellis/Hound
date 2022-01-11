//
//  TableViewCell.swift
//  MultipleViews
//
//  Created by Jonathan Xakellis on 11/4/20.
//  Copyright © 2020 Todd Perkins. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {

    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
