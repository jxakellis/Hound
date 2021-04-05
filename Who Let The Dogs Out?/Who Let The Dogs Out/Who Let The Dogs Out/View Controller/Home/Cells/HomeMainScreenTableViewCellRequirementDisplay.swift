//
//  HomeMainScreenTableViewCellRequirementDisplay.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/13/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol HomeMainScreenTableViewCellRequirementDisplayDelegate{
    
}

class HomeMainScreenTableViewCellRequirementDisplay: UITableViewCell {
    
    //MARK: IB
    
    @IBOutlet weak var requirementName: UILabel!
    
    @IBOutlet weak var dogName: UILabel!
    
    @IBOutlet weak var timeLeft: UILabel!
    
    //MARK: Properties
    
    var timeIntervalLeft: TimeInterval?
    
    var requirementSource: Requirement! = nil
    
    //MARK: Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
        requirementName.adjustsFontSizeToFitWidth = true
        dogName.adjustsFontSizeToFitWidth = true
        timeLeft.adjustsFontSizeToFitWidth = true
    }
    
    func setup(parentDogName: String, requirementPassed: Requirement) {
        self.requirementSource = requirementPassed
        requirementName.text = requirementPassed.requirementName
        dogName.text = parentDogName
        
        if TimingManager.isPaused == true {
            timeLeft.text = String.convertToReadable(interperateTimeInterval: requirementPassed.countDownComponents.executionInterval - requirementPassed.countDownComponents.intervalElapsed)
            self.timeIntervalLeft = (requirementPassed.countDownComponents.executionInterval - requirementPassed.countDownComponents.intervalElapsed)
        }
        else{
            let fireDate: Date = TimingManager.timerDictionary[parentDogName]![requirementPassed.requirementName]!.fireDate
            
            if Date().distance(to: fireDate) <= 0 {
                //timeSinceLastExecution.text = "It's Happening"
                timeLeft.attributedText = NSAttributedString(string: "No More Time Left", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: .semibold)])
            }
            else {
                self.timeIntervalLeft = Date().distance(to: fireDate)
                
                let timeLeftText = String.convertToReadable(interperateTimeInterval: self.timeIntervalLeft!)
                
                timeLeft.attributedText = NSAttributedString(string: timeLeftText, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: .regular)])
                    
                timeLeft.attributedText = timeLeft.text!.withFontAtEnd(text: " Left", font: UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: .semibold))
                
                //let timeSinceLastExecutionText = String.convertToReadable(interperateTimeInterval: requirementPassed.executionBasis.distance(to: Date()))
                
               // timeSinceLastExecution.attributedText = NSAttributedString(string: timeSinceLastExecutionText, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 17, weight: .regular)])
                
               // timeSinceLastExecution.attributedText = timeSinceLastExecution.text!.withFontAtEnd(text: " Since Last Time", font: UIFont.systemFont(ofSize: 17, weight: .semibold))
            }
        }
        
        
        
        
    }
    
}
