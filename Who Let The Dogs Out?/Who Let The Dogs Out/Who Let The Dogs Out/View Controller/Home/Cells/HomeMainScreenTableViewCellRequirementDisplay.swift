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
    @IBOutlet weak var timeSinceLastExecution: UILabel!
    
    func setup(parentDogName: String, requirementPassed: Requirement) {
        self.requirementSource = requirementPassed
        requirementName.text = requirementPassed.name
        dogName.text = parentDogName
        
        if TimingManager.isPaused == true {
            timeLeft.text = String.convertTimeIntervalToReadable(interperateTimeInterval: requirementPassed.executionInterval - requirementPassed.intervalElapsed)
            self.timeIntervalLeft = (requirementPassed.executionInterval - requirementPassed.intervalElapsed)
        }
        else{
            let fireDate = TimingManager.timerDictionary[parentDogName]![requirementPassed.name]!!.fireDate
            if Date().distance(to: fireDate) <= 0 {
                timeSinceLastExecution.text = "It's Happening"
                timeLeft.attributedText = NSAttributedString(string: "No More Time Left", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .semibold)])
            }
            else {
                self.timeIntervalLeft = Date().distance(to: fireDate)
                
                let timeLeftText = String.convertTimeIntervalToReadable(interperateTimeInterval: self.timeIntervalLeft!)
                
                timeLeft.attributedText = NSAttributedString(string: timeLeftText, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .regular)])
                    
                timeLeft.attributedText = timeLeft.text!.withFontAtEnd(text: " Left", font: UIFont.systemFont(ofSize: 17, weight: .semibold))
                
                let timeSinceLastExecutionText = String.convertTimeIntervalToReadable(interperateTimeInterval: requirementPassed.lastExecution.distance(to: Date()))
                
                timeSinceLastExecution.attributedText = NSAttributedString(string: timeSinceLastExecutionText, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .regular)])
                
                timeSinceLastExecution.attributedText = timeSinceLastExecution.text!.withFontAtEnd(text: " Since Last Time", font: UIFont.systemFont(ofSize: 17, weight: .semibold))
            }
        }
        
        
        
        
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        requirementName.adjustsFontSizeToFitWidth = true
        dogName.adjustsFontSizeToFitWidth = true
        timeLeft.adjustsFontSizeToFitWidth = true
    }
    
}
