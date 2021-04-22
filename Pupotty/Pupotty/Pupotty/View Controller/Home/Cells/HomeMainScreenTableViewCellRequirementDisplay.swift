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
    
    var requirementSource: Requirement! = nil
    
    var parentDogName: String! = nil
    
    //MARK: Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
        requirementName.adjustsFontSizeToFitWidth = true
        dogName.adjustsFontSizeToFitWidth = true
        timeLeft.adjustsFontSizeToFitWidth = true
    }
    
    func setup(parentDogName: String, requirementPassed: Requirement) {
        self.requirementSource = requirementPassed
        self.parentDogName = parentDogName
        requirementName.text = requirementPassed.requirementName
        dogName.text = parentDogName
        
        if TimingManager.isPaused == true {
            timeLeft.text = String.convertToReadable(interperateTimeInterval: requirementPassed.countDownComponents.executionInterval - requirementPassed.countDownComponents.intervalElapsed)
        }
        else{
            let fireDate: Date = TimingManager.timerDictionary[parentDogName]![requirementPassed.requirementName]!.fireDate
            
            if Date().distance(to: fireDate) <= 0 {
                //timeSinceLastExecution.text = "It's Happening"
                timeLeft.attributedText = NSAttributedString(string: "No More Time Left", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: .semibold)])
            }
            else {
                
                let timeLeftText = String.convertToReadable(interperateTimeInterval: Date().distance(to: fireDate))
                
                timeLeft.attributedText = NSAttributedString(string: timeLeftText, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: .regular)])
                
                timeLeft.attributedText = timeLeft.text!.withFontAtEnd(text: " Left", font: UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: .semibold))
            }
        }
        
        
    }
    
    func reloadCell(){
        if TimingManager.isPaused == true {
            timeLeft.text = String.convertToReadable(interperateTimeInterval: requirementSource.countDownComponents.executionInterval - requirementSource.countDownComponents.intervalElapsed)
        }
        else{
            let fireDate: Date = TimingManager.timerDictionary[parentDogName]![requirementSource.requirementName]!.fireDate
            
            if Date().distance(to: fireDate) <= 0 {
                //timeSinceLastExecution.text = "It's Happening"
                timeLeft.attributedText = NSAttributedString(string: "No More Time Left", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: .semibold)])
            }
            else {
                
                let timeLeftText = String.convertToReadable(interperateTimeInterval: Date().distance(to: fireDate))
                
                timeLeft.attributedText = NSAttributedString(string: timeLeftText, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: .regular)])
                
                timeLeft.attributedText = timeLeft.text!.withFontAtEnd(text: " Left", font: UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: .semibold))
            }
        }
        
        
    }
    
}
