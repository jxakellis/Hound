//
//  HomeInformationViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/25/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class HomeInformationViewController: UIViewController {
    
    

    //MARK: - IB
    
    @IBOutlet weak var purposeBody: ScaledUILabel!
    
    @IBOutlet weak var howToUseBody: ScaledUILabel!
    
    @IBAction func willGoBack(_ sender: Any) {
        //self.performSegue(withIdentifier: "unwindToHomeViewController", sender: self)
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
        howToUseBodyAttributedText.append(NSAttributedString(string: "\nIf an alarm sounds and you do it, select \"Did it!\". This logs the event and sets the reminder to go off at its next scheduled time. If you complete a reminder early (before its alarm sounds) click on it, select \"Did it!\", and Hound will handle the rest.\n\n", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .regular)]))
        
        
        howToUseBodyAttributedText.append(NSAttributedString(string: "Snooze Reminder:", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .semibold)]))
        howToUseBodyAttributedText.append(NSAttributedString(string: "\nIf an alarm sounds and you cannot do it right away, select \"Snooze\". This will not log the reminder, but it will sound an alarm once it is done snoozing. The length of time that it snoozes is configurable in settings.\n\n", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .regular)]))
        
        howToUseBodyAttributedText.append(NSAttributedString(string: "Inactivate Reminder:", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .semibold)]))
        howToUseBodyAttributedText.append(NSAttributedString(string: "\nIf an alarm sounds and you do not want to deal with it, click \"Dismiss\". This won't fully disable the reminder, but it will sit inactive until you click it and select an option. Deactivating a reminder will not log it and will disable its alarms until you are ready to start using it again. To re-activate, just select \"Did it!\".\n\n", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .regular)]))
        
        
        howToUseBodyAttributedText.append(NSAttributedString(string: "Skip Reminder:", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .semibold)]))
        howToUseBodyAttributedText.append(NSAttributedString(string: "\nIf you complete a reminder early and do not want its alarm to sound, click on it and select \"Did it!\". This will log the reminder and handle its alarm. For a recurring reminder, it will start its countdown over right when the button is selected. For a time of day reminder, it will skip the scheduled alarm then function as usual.\n\n", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .regular)]))
        
        howToUseBodyAttributedText.append(NSAttributedString(string: "Disable Reminder:", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .semibold)]))
        howToUseBodyAttributedText.append(NSAttributedString(string: "\nIf you want to disable a reminder you can do it in two ways, either click on it and select \"Disable\" or go to the Dogs tab and toggle its slider. A disabled reminder's alarms will not sound but can be turned back on by re-enabling the reminder.", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .regular)]))
        howToUseBody.attributedText = howToUseBodyAttributedText
    }
    

}
