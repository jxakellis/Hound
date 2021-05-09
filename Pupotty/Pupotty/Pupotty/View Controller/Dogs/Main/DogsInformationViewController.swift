//
//  DogsInformationViewController.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 4/25/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class DogsInformationViewController: UIViewController {
    
    //MARK: - IB
    
    @IBOutlet private weak var purposeBody: CustomLabel!
    
    @IBOutlet private weak var howToUseBody: CustomLabel!
    
    @IBAction private func willGoBack(_ sender: Any) {
        //self.performSegue(withIdentifier: "unwindToDogsViewController", sender: self)
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupLabelText()
        
        purposeBody.removeConstraint(purposeBody.constraints[0])
        
        howToUseBody.removeConstraint(howToUseBody.constraints[0])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utils.presenter = self
    }
    
    ///Configures the body text to an attributed string, the headers are .semibold and rest is .regular, font size is the one specified in the storyboard
    private func setupLabelText(){
        
        let howToUseBodyAttributedText = NSMutableAttributedString(string: "Log Reminder:", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .semibold)])
        howToUseBodyAttributedText.append(NSAttributedString(string: "\nIf you complete a reminder early (before its alarm sounds) click on it, select \"Log ...\", and Pupotty will handle the rest.\n\n", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .regular)]))
        
        howToUseBodyAttributedText.append(NSAttributedString(string: "Create New:", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .semibold)]))
        howToUseBodyAttributedText.append(NSAttributedString(string: "\nTo create a new dog or reminder, click on the blue ⊕ and then the corresponding option.\n\n", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .regular)]))
        // You can also create a new reminder while editing a dog by clicking the blue \"+\" next to the word \"Reminders\".
        
        howToUseBodyAttributedText.append(NSAttributedString(string: "Manage Current:", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .semibold)]))
        howToUseBodyAttributedText.append(NSAttributedString(string: "\nTo disable or enable a reminder, simply toggle the blue slider. A disabled reminder will keep all of its data but its alarm will not sound, countdown, or update until re-enabled.\n\n", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .regular)]))
        
        
        howToUseBodyAttributedText.append(NSAttributedString(string: "Edit Current:", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .semibold)]))
        howToUseBodyAttributedText.append(NSAttributedString(string: "\nIf you want to modify a dog or reminder, click on it and select \"Edit ...\". From there you can see and change all of its information, excluding logs.\n\n", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .regular)]))
        
        
        howToUseBodyAttributedText.append(NSAttributedString(string: "Delete Current:", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .semibold)]))
        howToUseBodyAttributedText.append(NSAttributedString(string: "\nTo delete a dog or reminder, either swipe left on it or click on it and select \"Delete ...\".\n\n", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .regular)]))
        
        
        howToUseBodyAttributedText.append(NSAttributedString(string: "Reminder Timing:", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .semibold)]))
        howToUseBodyAttributedText.append(NSAttributedString(string: "\nA reminder can be either a recurring count down or a time of day alarm. A recurring count down automatically counts down from its set duration and only repeats once you respond to its alarm. A time of day countdown happens at a set time of day for every weekday that is selected.", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .regular)]))
        howToUseBody.attributedText = howToUseBodyAttributedText
    }

}
