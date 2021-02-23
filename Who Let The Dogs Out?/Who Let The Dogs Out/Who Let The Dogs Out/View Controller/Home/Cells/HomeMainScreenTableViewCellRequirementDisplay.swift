//
//  HomeMainScreenTableViewCellRequirementDisplay.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/13/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol HomeMainScreenTableViewCellDogRequirementDisplayDelegate{
    
}

class HomeMainScreenTableViewCellDogRequirementDisplay: UITableViewCell {

    //MARK: Main
    
    var timeIntervalLeft: TimeInterval?
    
    var requirementSource: Requirement! = nil
    
    @IBOutlet weak var requirementName: UILabel!
    
    @IBOutlet weak var dogName: UILabel!
    
    @IBOutlet weak var timeLeft: UILabel!
    
    func setup(parentDogName: String, requirementPassed: Requirement) {
        self.requirementSource = requirementPassed
        requirementName.text = requirementPassed.label
        dogName.text = parentDogName
        
        if TimingManager.pauseState.1 == true {
            timeLeft.text = String.convertTimeIntervalToReadable(interperateTimeInterval: requirementPassed.interval - requirementPassed.intervalElapsed, showSeconds: true)
            self.timeIntervalLeft = (requirementPassed.interval - requirementPassed.intervalElapsed)
        }
        else{
            let fireDate = TimingManager.timerDictionary[parentDogName]![requirementPassed.label]!.fireDate
            self.timeIntervalLeft = Date().distance(to: fireDate)
            timeLeft.text = String.convertTimeIntervalToReadable(interperateTimeInterval: self.timeIntervalLeft!, showSeconds: true)
        }
        timeLeft.text = timeLeft.text! + " Left"
        
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        requirementName.adjustsFontSizeToFitWidth = true
        dogName.adjustsFontSizeToFitWidth = true
        timeLeft.adjustsFontSizeToFitWidth = true
        // Initialization code
    }

}
