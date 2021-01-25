//
//  DogsInstantiateRequirementViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

//Delegate to pass setup requirement back to table view
protocol DogsInstantiateRequirementViewControllerDelegate {
    func didAddToList (requirement: Requirement) throws
}

class DogsInstantiateRequirementViewController: UIViewController {

    
    var delegate: DogsInstantiateRequirementViewControllerDelegate! = nil
    
    @IBOutlet private weak var addToList: UIButton!
    @IBOutlet private weak var requirementName: UITextField!
    @IBOutlet private weak var requirementDescription: UITextField!
    @IBOutlet private weak var requirementInterval: UIDatePicker!
    
    //Takes all fields (configured or not), checks if their parameters are valid, and then if it passes all tests calls on the delegate to pass the configured requirement back to table view.
    @IBAction private func addToList(_ sender: Any) {
        var tempRequirement = Requirement(initDate: Date())
        
        do {
            try tempRequirement.changeLabel(newLabel: requirementName.text)
            try tempRequirement.changeDescription(newDescription: requirementDescription.text)
            try tempRequirement.changeInterval(newInterval: requirementInterval.countDownDuration)
            try delegate.didAddToList(requirement: tempRequirement)
            navigationController?.popViewController(animated: true)
        }
        catch DogRequirementError.labelInvalid {
            alertForError(message: "Invalid requirement name")
        }
        catch DogRequirementError.descriptionInvalid{
            alertForError(message: "Invalid requirement description")
        }
        catch DogRequirementError.intervalInvalid {
            alertForError(message: "Invalid requirement time interval")
        }
        catch DogRequirementManagerError.requirementAlreadyPresent {
            alertForError(message: "\"\(requirementName.text!)\" already present, please try a different name")
        }
        catch {
            alertForError(message: "Error: \(error)")
        }
        
        
    }
    
    //If an error is found, call this method to display an alert controller popup stating the error to the user
    private func alertForError(message: String){
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        defaults()
    }
    
    //default values and configs
    private func defaults(){
        requirementName.text = RequirementConstant.defaultLabel
        requirementDescription.text = RequirementConstant.defaultDescription
        requirementInterval.countDownDuration = TimeInterval(RequirementConstant.defaultTimeInterval)
        
        addToList.layer.cornerRadius = 8.0
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
