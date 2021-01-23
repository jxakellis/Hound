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
        timeInterval.text = convertTimeIntervalToReadable(interperateTimeInterval: initTimeInterval)
    }
    
    func convertTimeIntervalToReadable(interperateTimeInterval: TimeInterval) -> String {
        let intTime = Int(interperateTimeInterval.rounded())
        
        let numHours = Int(intTime / 3600)
        let numMinutes = Int((intTime % 3600)/60)
        if numHours > 1 && numMinutes > 1{
            return "\(numHours) Hours \(numMinutes) Minutes"
        }
        else if numHours > 1 && numMinutes == 1 {
            return "\(numHours) Hours \(numMinutes) Minute"
        }
        else if numHours == 1 && numMinutes > 1 {
            return "\(numHours) Hour \(numMinutes) Minutes"
        }
        else{
            return "\(numHours) Hour \(numMinutes) Minute"
        }
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        timeInterval.adjustsFontSizeToFitWidth = true
        label.adjustsFontSizeToFitWidth = true
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
