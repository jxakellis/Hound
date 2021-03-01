//
//  DogsRequirementTableViewCell.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit
protocol DogsRequirementTableViewCellDelegate {
    func didClickTrash(dogName: String)
}


class DogsRequirementTableViewCell: UITableViewCell {
    
    var delegate: DogsRequirementTableViewCellDelegate! = nil
    
    @IBOutlet private weak var timeInterval: UILabel!
    @IBOutlet private weak var name: UILabel!
    
    
    //When the trash button icon is clicked it executes this func, thru delegate finds a requirement with a matching name and then deletes it (handled elsewhere tho)
    @IBAction private func didClickTrash(_ sender: Any) {
        delegate.didClickTrash(dogName: name.text!)
    }
    
    //sets label to initLabel
    func setName(initName: String){
        name.text = initName
    }
    
    //set time interval to initTimeInterval
    func setTimeInterval(initTimeInterval: TimeInterval){
        timeInterval.text = String.convertTimeIntervalToReadable(interperateTimeInterval: initTimeInterval)
    }
    
    //when cell is awoken / init, this is executed
    override func awakeFromNib() {
        super.awakeFromNib()
        timeInterval.adjustsFontSizeToFitWidth = true
        name.adjustsFontSizeToFitWidth = true
        // Initialization code
        self.contentMode = .center
        self.imageView?.contentMode = .center
    }
    
    //when the cell is selected, code is run, currently unconfigured
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
