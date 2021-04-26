//
//  DogsAddDogViewController.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 1/19/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddDogViewControllerDelegate{
    func didAddDog(sender: Sender, newDog: Dog) throws
    func didUpdateDog(sender: Sender, formerName: String, updatedDog: Dog) throws
    func didRemoveDog(sender: Sender, removedDogName: String)
}

class DogsAddDogViewController: UIViewController, DogsRequirementNavigationViewControllerDelegate, UITextFieldDelegate{
    
    //MARK: Requirement Table VC Delegate
    
    //assume all requirements are valid due to the fact that they are all checked and validated through DogsRequirementTableViewController
    func didUpdateRequirements(newRequirementList: [Requirement]) {
        updatedRequirements = newRequirementList
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    
    
    //MARK: IB
    
    @IBOutlet private weak var dogName: UITextField!
    @IBOutlet private weak var dogEnableStatus: UISwitch!
    
    @IBOutlet private weak var embeddedTableView: UIView!
    
    @IBOutlet private weak var addDogButtonBackground: UIButton!
    @IBOutlet private weak var addDogButton: UIButton!
    //When the add button is clicked, runs a series of checks. Makes sure the name and description of the dog is valid, and if so then passes information up chain of view controllers to DogsViewController.
    @IBAction private func willAddDog(_ sender: Any) {
        
        let updatedDog = targetDog.copy() as! Dog
        
        do{
            try updatedDog.dogTraits.changeDogName(newDogName: dogName.text)
            
            updatedDog.setEnable(newEnableStatus: dogEnableStatus.isOn)
            
            if updatedRequirements != nil {
                updatedDog.dogRequirments.requirements.removeAll()
                try! updatedDog.dogRequirments.addRequirement(newRequirements: self.updatedRequirements!)
            }
            
        }
        catch {
            ErrorProcessor.handleError(sender: Sender(origin: self, localized: self), error: error)
            return
        }
        
        
        do{
            if isUpdating == true{
                try delegate.didUpdateDog(sender: Sender(origin: self, localized: self), formerName: targetDog.dogTraits.dogName, updatedDog: updatedDog)
                self.performSegue(withIdentifier: "unwindToDogsViewController", sender: self)
            }
            else{
                try delegate.didAddDog(sender: Sender(origin: self, localized: self), newDog: updatedDog)
                self.performSegue(withIdentifier: "unwindToDogsViewController", sender: self)
            }
        }
        catch {
            ErrorProcessor.handleError(sender: Sender(origin: self, localized: self), error: error)
        }
        
    }
    
    @IBOutlet weak var dogRemoveButton: UIBarButtonItem!
    
    @IBAction func willRemoveDog(_ sender: Any) {
        let removeDogConfirmation = GeneralAlertController(title: "Are you sure you want to delete \"\(dogName.text ?? targetDog.dogTraits.dogName)\"", message: nil, preferredStyle: .alert)
        
        let alertActionRemove = UIAlertAction(title: "Delete", style: .destructive) { (UIAlertAction) in
            self.delegate.didRemoveDog(sender: Sender(origin: self, localized: self), removedDogName: self.targetDog.dogTraits.dogName)
            self.performSegue(withIdentifier: "unwindToDogsViewController", sender: self)
        }
        
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        removeDogConfirmation.addAction(alertActionRemove)
        removeDogConfirmation.addAction(alertActionCancel)
        
        AlertPresenter.shared.enqueueAlertForPresentation(removeDogConfirmation)
    }
    
    
    @IBOutlet private weak var cancelAddDogButton: UIButton!
    @IBOutlet private weak var cancelAddDogButtonBackground: UIButton!
    
    @IBAction private func cancelAddDogButton(_ sender: Any) {
        let unsavedInformationConfirmation = GeneralAlertController(title: "Are you sure you want to exit?", message: "Any changes you have made won't be saved", preferredStyle: .alert)
        
        let alertActionExit = UIAlertAction(title: "Yes, I don't want to save", style: .default) { (UIAlertAction) in
            self.performSegue(withIdentifier: "unwindToDogsViewController", sender: self)
        }
        
        let alertActionCancel = UIAlertAction(title: "Cancel", style: .cancel) { (UIAlertAction) in
            //
        }
        
        unsavedInformationConfirmation.addAction(alertActionExit)
        unsavedInformationConfirmation.addAction(alertActionCancel)
        
        AlertPresenter.shared.enqueueAlertForPresentation(unsavedInformationConfirmation)
        
    }

    //MARK: Properties
    
    var dogsRequirementNavigationViewController: DogsRequirementNavigationViewController! = nil
    
    var targetDog = Dog()
    
    var delegate: DogsAddDogViewControllerDelegate! = nil
    
    var isUpdating: Bool = false
    
    var isAddingRequirement: Bool = false
    
    private var updatedRequirements: [Requirement]? = nil
    
    //MARK: Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupToHideKeyboardOnTapOnView()
        
        self.view.bringSubviewToFront(addDogButtonBackground)
        self.view.bringSubviewToFront(addDogButton)

        self.view.bringSubviewToFront(cancelAddDogButtonBackground)
        self.view.bringSubviewToFront(cancelAddDogButton)
        
        dogName.delegate = self
        
        willInitalize()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utils.presenter = self
    }
    
    
    ///Called to initalize all data, if a dog is passed then it uses that, otherwise uses default
    private func willInitalize(){
        dogName.text = targetDog.dogTraits.dogName
        dogEnableStatus.isOn = targetDog.getEnable()
        //has to copy requirements so changed that arent saved don't use reference data property to make actual modification
        dogsRequirementNavigationViewController.didPassRequirements(sender: Sender(origin: self, localized: self), passedRequirements: targetDog.dogRequirments.copy() as! RequirementManager)
        
        //changes text and performs certain actions if adding a new dog vs updating one
        if isUpdating == true {
            dogRemoveButton.isEnabled = true
            self.navigationItem.title = "Update Dog"
            if isAddingRequirement == true {
                dogsRequirementNavigationViewController.dogsRequirementTableViewController.performSegue(withIdentifier: "dogsInstantiateRequirementViewController", sender: self)
            }
        }
        else {
            dogRemoveButton.isEnabled = false
            self.navigationItem.title = "Create Dog"
        }
 
    }
    
    ///Hides the big gray back button and big blue checkmark, don't want access to them while editting a requirement.
    func willHideButtons(isHidden: Bool){
        if isHidden == false {
            addDogButton.isHidden = false
            addDogButtonBackground.isHidden = false
            cancelAddDogButton.isHidden = false
            cancelAddDogButtonBackground.isHidden = false
        }
        else {
            addDogButton.isHidden = true
            addDogButtonBackground.isHidden = true
            cancelAddDogButton.isHidden = true
            cancelAddDogButtonBackground.isHidden = true
        }
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dogRequirementNavigationController"{
            dogsRequirementNavigationViewController = segue.destination as? DogsRequirementNavigationViewController
            dogsRequirementNavigationViewController.passThroughDelegate = self
        }
        
        
    }
}
