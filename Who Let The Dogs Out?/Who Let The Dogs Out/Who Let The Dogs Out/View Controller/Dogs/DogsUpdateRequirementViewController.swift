//
//  DogsUpdateRequirementViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/26/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsUpdateRequirementViewControllerDelegate {
    func didUpdateRequirement(parentDogName: String, formerName: String, updatedRequirement: Requirement) throws
}

class DogsUpdateRequirementViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate {

    //MARK: UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.dismissKeyboard()
        return false
    }
    
    //MARK: IBOutlet and Action Buttons
    
    //Buttons to manage the information fate, whether to update or to cancel
    
    @IBOutlet private weak var updateRequirementButton: UIButton!
    @IBOutlet private weak var updateRequirementButtonBackground: UIButton!
    
    @IBOutlet private weak var cancelUpdateRequirementButton: UIButton!
    
    @IBOutlet private weak var cancelUpdateRequirementButtonBackground: UIButton!
    
    ///Takes all fields (configured or not), checks if their parameters are valid, and then if it passes all tests calls on the delegate to pass the configured requirement to DogsViewController
    @IBAction private func willUpdate(_ sender: Any) {
        var tempRequirement = Requirement()
        
        do {
            try tempRequirement.changeName(newName: requirementName.text)
            try tempRequirement.changeDescription(newDescription: requirementDescription.text)
            try tempRequirement.changeInterval(newInterval: requirementInterval.countDownDuration)
            try delegate.didUpdateRequirement(parentDogName: parentDogName, formerName: requirement.name, updatedRequirement: tempRequirement)
            self.dismiss(animated: true, completion: nil)
        }
        catch {
            ErrorProcessor.handleError(error: error, sender: self)
        }
    }
    
    ///The cancel / exit button was pressed, dismisses view to complete intended action
    @IBAction private func willCancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Other IBOutlets
    
    @IBOutlet private weak var requirementName: UITextField!
    
    @IBOutlet private weak var requirementDescription: UITextField!
    
    @IBOutlet private weak var requirementInterval: UIDatePicker!
    
    @IBAction private func requirementIntervalValueChanged(_ sender: Any) {
        self.dismissKeyboard()
    }
    
    //MARK: Properties
    
    var delegate: DogsUpdateRequirementViewControllerDelegate! = nil
    
    var requirement: Requirement! = nil
    
    var parentDogName: String! = nil
    
    //MARK: Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Keyboard first responder management
        self.setupToHideKeyboardOnTapOnView()
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tap.delegate = self
        requirementInterval.addGestureRecognizer(tap)
        
        requirementName.delegate = self
        requirementDescription.delegate = self
        
        self.view.bringSubviewToFront(updateRequirementButtonBackground)
        self.view.bringSubviewToFront(updateRequirementButton)
        
        self.view.bringSubviewToFront(cancelUpdateRequirementButtonBackground)
        self.view.bringSubviewToFront(cancelUpdateRequirementButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utils.presenter = self
        requirementName.text = requirement.name
        requirementDescription.text = requirement.description
        requirementInterval.countDownDuration = requirement.executionInterval
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
