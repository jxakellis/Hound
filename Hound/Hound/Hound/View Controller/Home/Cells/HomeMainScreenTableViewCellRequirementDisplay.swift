//
//  HomeMainScreenTableViewCellRequirementDisplay.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/13/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol HomeMainScreenTableViewCellRequirementDisplayDelegate{
    
}

class HomeMainScreenTableViewCellRequirementDisplay: UITableViewCell {
    
    //MARK: - IB
    
    @IBOutlet private weak var requirementType: CustomLabel!
    
    @IBOutlet private weak var dogName: CustomLabel!
    
    @IBOutlet private weak var timeLeft: CustomLabel!
    
    //MARK: - Properties
    
    var requirementSource: Requirement! = nil
    
    var parentDogName: String! = nil
    
    //MARK: - Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func setup(parentDogName: String, requirementPassed: Requirement) {
        self.requirementSource = requirementPassed
        self.parentDogName = parentDogName
        requirementType.text = requirementPassed.requirementType.rawValue
        dogName.text = parentDogName
        
        setupTimeLeftText()
        
    }
    
    func reloadCell(){
        setupTimeLeftText()
    }
    
    private func setupTimeLeftText(){
        if TimingManager.isPaused == true {
            timeLeft.text = String.convertToReadable(interperateTimeInterval: requirementSource.countDownComponents.executionInterval - requirementSource.countDownComponents.intervalElapsed)
        }
        else{
            let fireDate: Date = TimingManager.timerDictionary[parentDogName]![requirementSource.uuid]!.fireDate
            
            if Date().distance(to: fireDate) <= 0 {
                //timeSinceLastExecution.text = "It's Happening"
                timeLeft.attributedText = NSAttributedString(string: "No More Time Left", attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: .semibold)])
            }
            else {
                
                let timeLeftText = String.convertToReadable(interperateTimeInterval: Date().distance(to: fireDate))
                
                timeLeft.attributedText = NSAttributedString(string: timeLeftText, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: .regular)])
                
                timeLeft.attributedText = timeLeft.text!.addingFontToEnd(text: " Left", font: UIFont.systemFont(ofSize: timeLeft.font.pointSize, weight: .semibold))
            }
        }
    }
    
}
