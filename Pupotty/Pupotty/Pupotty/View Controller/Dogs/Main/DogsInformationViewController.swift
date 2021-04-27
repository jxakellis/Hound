//
//  DogsInformationViewController.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 4/25/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class DogsInformationViewController: UIViewController {
    
    //MARK: IB
    
    @IBOutlet private weak var purposeBody: CustomLabel!
    
    @IBOutlet private weak var howToUseBody: CustomLabel!
    
    @IBAction private func willGoBack(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToDogsViewController", sender: self)
    }
    
    
    //MARK: Main

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureLabelText()
        
        purposeBody.frame.size = (purposeBody.text?.boundingFrom(font: purposeBody.font, width: purposeBody.frame.width))!
        
        purposeBody.removeConstraint(purposeBody.constraints[0])
        
        howToUseBody.frame.size = (howToUseBody.text?.boundingFrom(font: howToUseBody.font, width: howToUseBody.frame.width))!
        
        howToUseBody.removeConstraint(howToUseBody.constraints[0])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utils.presenter = self
    }
    
    ///Configures the body text to an attributed string, the headers are .semibold and rest is .regular, font size is the one specified in the storyboard
    private func configureLabelText(){
        let howToUseBodyAttributedText = NSMutableAttributedString(string: "Create New:", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .semibold)])
        howToUseBodyAttributedText.append(NSAttributedString(string: "\nTo create a new dog or reminder, click on the blue plus circle (located in bottom right) and then the corresponding option. You can also create a new reminder while editing a dog by clicking the small blue plus button next to the word \"Reminders\"\n\n", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .regular)]))
        
        
        howToUseBodyAttributedText.append(NSAttributedString(string: "Manage Current:", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .semibold)]))
        howToUseBodyAttributedText.append(NSAttributedString(string: "\nTo disable or enable a reminder, simply toggle the blue slider. A disabled reminder will keep all of its data but its alarm will not sound, update, or display until re-enabled.\n\n", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .regular)]))
        
        
        howToUseBodyAttributedText.append(NSAttributedString(string: "Edit Current:", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .semibold)]))
        howToUseBodyAttributedText.append(NSAttributedString(string: "\nTo modify a dog or reminder, click on the desired one. From there you can see and change all of its information, excluding logs. The same principles apply inside any of these menus for managing, editing, and deleting.\n\n", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .regular)]))
        
        
        howToUseBodyAttributedText.append(NSAttributedString(string: "Delete Current:", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .semibold)]))
        howToUseBodyAttributedText.append(NSAttributedString(string: "\nTo delete a dog or reminder, swipe left on it. Another way to delete is to click on one then click the trash can icon located in the top right.\n\n", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .regular)]))
        
        
        howToUseBodyAttributedText.append(NSAttributedString(string: "Reminder Timing:", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .semibold)]))
        howToUseBodyAttributedText.append(NSAttributedString(string: "\nA reminder can be either a recurring count down or a time of day alarm. A recurring count down automatically counts down from the interval you set it to and will repeat itself once responded to. A time of day countdown happens at a set time of day for every weekday that is selected.", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .regular)]))
        howToUseBody.attributedText = howToUseBodyAttributedText
    }

}
