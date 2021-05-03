//
//  LogsInformationViewController.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 4/25/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class LogsInformationViewController: UIViewController {
    
    
    //MARK: - IB
    
    @IBOutlet weak var purposeBody: CustomLabel!
    
    @IBOutlet weak var howToUseBody: CustomLabel!
    
    @IBAction func willGoBack(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToLogsViewController", sender: self)
    }
    
    
    //MARK: - Main

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
        let howToUseBodyAttributedText = NSMutableAttributedString(string: "Logs:", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .semibold)])
        howToUseBodyAttributedText.append(NSAttributedString(string: "\nLogs keep track of everytime you took your dog out and at what time. They have a built-in notes feature which allows you to write anything important that also occured.\n\n", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .regular)]))
        
        howToUseBodyAttributedText.append(NSAttributedString(string: "Edit Notes:", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .semibold)]))
        howToUseBodyAttributedText.append(NSAttributedString(string: "\nTo edit a note, which by default is blank, simply click on the desired log. In the pop-up, enter your note and click \"Submit\".\n\n", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .regular)]))
        
        howToUseBodyAttributedText.append(NSAttributedString(string: "Add Arbitrary Log:", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .semibold)]))
        howToUseBodyAttributedText.append(NSAttributedString(string: "\nTo add an arbitrary log, click the on the blue plus circle located in the bottom right. This will allow you to log an independent, unscheduled event; this log will not create, modify, or delete any reminders or alarms. For example, once in a while you take your dog to the vet. You record this with an arbitrary log, so you remember, but no further action by Pupotty is needed.\n\n", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .regular)]))
        
        
        howToUseBodyAttributedText.append(NSAttributedString(string: "Delete Logs:", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .semibold)]))
        howToUseBodyAttributedText.append(NSAttributedString(string: "\nTo delete a log, along with its accompanying note, swipe left on it.\n\n", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .regular)]))
        
        
        howToUseBodyAttributedText.append(NSAttributedString(string: "Filtering and Sorting:", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .semibold)]))
        howToUseBodyAttributedText.append(NSAttributedString(string: "\nTo Filter by either a reminder or a dog, click \"Filter\" then the select the desired option. Filters are automatically removed if a new log is added, or they can be manually removed by selecting the option again.", attributes: [.font:UIFont.systemFont(ofSize: howToUseBody.font.pointSize, weight: .regular)]))
        howToUseBody.attributedText = howToUseBodyAttributedText
    }

}
