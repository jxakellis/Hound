//
//  IntroductionViewController.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 4/26/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol IntroductionViewControllerDelegate {
    func didSetDogName(sender: Sender, dogName: String)
}

class IntroductionViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismissKeyboard()
        return false
    }
    
    //MARK: - IB
    
    @IBOutlet private weak var dogNameDescription: CustomLabel!
    
    @IBOutlet private weak var dogName: UITextField!
    
    @IBOutlet private weak var notificationsDescription: CustomLabel!
    
    @IBOutlet private weak var helpDescription: CustomLabel!
    
    @IBOutlet private weak var continueButton: UIButton!
    
    ///Clicked continues button at the bottom to dismiss
    @IBAction private func didContinue(_ sender: Any) {
        //data passage handled in view will disappear as the view can also be swiped down instead of hitting the continue button.
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet private weak var isNotificationEnabledSwitch: UISwitch!
    
    ///Handles the toggling of the notification switch, if its the first time then it requests notification authorization.
    @IBAction private func didToggleNotifications(_ sender: Any) {
        self.dismissKeyboard()
        
        if isNotificationEnabledSwitch.isOn == true {
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (isGranted, error) in
                NotificationConstant.isNotificationAuthorized = isGranted
                NotificationConstant.isNotificationEnabled = isGranted
                NotificationConstant.shouldFollowUp = isGranted
                
                DispatchQueue.main.async {
                    self.isNotificationEnabledSwitch.setOn(isGranted, animated: true)
                    self.isNotificationEnabledSwitch.isEnabled = isGranted
                }
                
            }
        }
    }
    
    //MARK: - Properties
    
    var delegate: IntroductionViewControllerDelegate! = nil
    
    //MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scaleLabelFrames()
        
        continueButton.layer.cornerRadius = 8.0
        
        dogName.delegate = self
        
        self.setupToHideKeyboardOnTapOnView()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utils.presenter = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //synchronizes data when setup is done (aka disappearing)
        if dogName.text != nil && dogName.text?.trimmingCharacters(in: .whitespacesAndNewlines) != ""{
            delegate.didSetDogName(sender: Sender(origin: self, localized: self), dogName: dogName.text!)
        }
        NotificationConstant.isNotificationEnabled = isNotificationEnabledSwitch.isOn
        NotificationConstant.shouldFollowUp = isNotificationEnabledSwitch.isOn
    }
    
    ///Scales the frames of different labels so that they fit their text with the set font perfectly.
    private func scaleLabelFrames(){
        dogNameDescription.frame.size = (dogNameDescription.text?.boundingFrom(font: dogNameDescription.font, width: dogNameDescription.frame.width))!
        
        dogNameDescription.removeConstraint(dogNameDescription.constraints[0])
        
        notificationsDescription.frame.size = (notificationsDescription.text?.boundingFrom(font: notificationsDescription.font, width: notificationsDescription.frame.width))!
        
        notificationsDescription.removeConstraint(notificationsDescription.constraints[0])
        
        helpDescription.frame.size = (helpDescription.text?.boundingFrom(font: helpDescription.font, width: helpDescription.frame.width))!
        
        helpDescription.removeConstraint(helpDescription.constraints[0])
    }
}
