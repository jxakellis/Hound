//
//  DogsAddDogViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 1/19/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddDogViewControllerDelegate{
    func didAddDog(newDog: Dog) throws
    func didUpdateDog(formerName: String, updatedDog: Dog) throws
}

class DogsAddDogViewController: UIViewController, DogsRequirementNavigationViewControllerDelegate, UITextFieldDelegate{
    
    //MARK: Requirement Table VC Delegate
    
    //assume all requirements are valid due to the fact that they are all checked and validated through DogsRequirementTableViewController
    func didUpdateRequirements(newRequirementList: [Requirement]) {
        dog.dogRequirments.clearRequirements()
        try! dog.dogRequirments.addRequirement(newRequirements: newRequirementList)
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //MARK: Properties
    
    var dogsRequirementNavigationViewController: DogsRequirementNavigationViewController! = nil
    
    var dog = Dog()
    
    var delegate: DogsAddDogViewControllerDelegate! = nil
    
    var updateDogTuple: (Bool, String) = (false, "")
    
    //MARK: View IBOutlets and IBActions
    
    @IBOutlet weak var dogName: UITextField!
    @IBOutlet weak var dogDescription: UITextField!
    
    @IBOutlet weak var embeddedTableView: UIView!
    
    
    @IBOutlet weak var addDogButtonBackground: UIButton!
    @IBOutlet weak var addDogButton: UIButton!
    //When the add button is clicked, runs a series of checks. Makes sure the name and description of the dog is valid, and if so then passes information up chain of view controllers to DogsViewController.
    @IBAction func willAddDog(_ sender: Any) {
        
        do{
            try dog.dogSpecifications.changeDogSpecifications(key: "name", newValue: dogName.text)
            try dog.dogSpecifications.changeDogSpecifications(key: "description", newValue: dogDescription.text)
        }
        catch {
            ErrorProcessor.handleError(error: error, sender: self)
            return
        }
        
        
        do{
            if updateDogTuple.0 == true{
                try delegate.didUpdateDog(formerName: updateDogTuple.1, updatedDog: dog)
                dismiss(animated: true, completion: nil)
            }
            else{
                try delegate.didAddDog(newDog: dog)
                dismiss(animated: true, completion: nil)
            }
        }
        catch {
            ErrorProcessor.handleError(error: error, sender: self)
        }
        
    }
    
    @IBOutlet weak var cancelAddDogButton: UIButton!
    @IBOutlet weak var cancelAddDogButtonBackground: UIButton!
    
    @IBAction func cancelAddDogButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupToHideKeyboardOnTapOnView()
        
        self.view.bringSubviewToFront(addDogButtonBackground)
        self.view.bringSubviewToFront(addDogButton)

        self.view.bringSubviewToFront(cancelAddDogButtonBackground)
        self.view.bringSubviewToFront(cancelAddDogButton)
        
        willInitalize()
        
        ibOutletSetup()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utils.presenter = self
    }
    
    private func ibOutletSetup(){
        dogName.delegate = self
        dogDescription.delegate = self
    }
    
    func willInitalize(){
        if updateDogTuple.0 == true {
            try! dogName.text = dog.dogSpecifications.getDogSpecification(key: "name")
            try! dogDescription.text = dog.dogSpecifications.getDogSpecification(key: "description")
        }
        else{
            dogName.text = "Fido"
            dogDescription.text = "Friendly"
        }
    }
    
    func willHideButtons(isHidden: Bool){
        if isHidden == false {
            addDogButton.isEnabled = true
            addDogButton.isHidden = false
            addDogButtonBackground.isEnabled = true
            addDogButtonBackground.isHidden = false
            cancelAddDogButton.isEnabled = true
            cancelAddDogButton.isHidden = false
            cancelAddDogButtonBackground.isEnabled = true
            cancelAddDogButtonBackground.isHidden = false
        }
        else {
            addDogButton.isEnabled = false
            addDogButton.isHidden = true
            addDogButtonBackground.isEnabled = false
            addDogButtonBackground.isHidden = true
            cancelAddDogButton.isEnabled = false
            cancelAddDogButton.isHidden = true
            cancelAddDogButtonBackground.isEnabled = false
            cancelAddDogButtonBackground.isHidden = true
        }
    }
    
    //MARK: DogsViewController
    
    //Called by superview to pass down new requirements to subview, used when editting a dog
    func didPassRequirements(passedRequirements: RequirementManager){
        dogsRequirementNavigationViewController.didPassRequirements(passedRequirements: passedRequirements)
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
