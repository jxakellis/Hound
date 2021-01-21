//
//  DogsRequirementTableViewCell.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit
protocol DogsRequirementTableViewCellDelegate {
    func trashClicked(dogName: String)
}


class DogsRequirementTableViewCell: UITableViewCell {

    var delegate: DogsRequirementTableViewCellDelegate! = nil
    
    @IBOutlet weak var timeInterval: UILabel!
    @IBOutlet weak var label: UILabel!
    
    @IBAction func trashClicked(_ sender: Any) {
        delegate.trashClicked(dogName: label.text!)
    }
    
    func setLabel(initLabel: String){
        label.text = initLabel
    }
    
    func setTimeInterval(initTimeInterval: TimeInterval){
        timeInterval.text = initTimeInterval.description
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
