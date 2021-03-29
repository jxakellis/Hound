//
//  DogsAddDogViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 1/19/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddDogViewControllerDelegate{
    func didAddDog(sender: Sender, newDog: Dog) throws
    func didUpdateDog(sender: Sender, formerName: String, updatedDog: Dog) throws
}

class DogsAddDogViewController: UIViewController, DogsRequirementNavigationViewControllerDelegate, UITextFieldDelegate{
    
    //MARK: Requirement Table VC Delegate
    
    //assume all requirements are valid due to the fact that they are all checked and validated through DogsRequirementTableViewController
    func didUpdateRequirements(newRequirementList: [Requirement]) {
        targetDog.dogRequirments.clearRequirements()
        try! targetDog.dogRequirments.addRequirement(newRequirements: newRequirementList)
    }
    
    //MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    
    
    //MARK: IB
    
    @IBOutlet weak var dogName: UITextField!
    @IBOutlet weak var dogDescription: UITextField!
    @IBOutlet weak var dogEnableStatus: UISwitch!
    
    @IBOutlet weak var embeddedTableView: UIView!
    
    
    @IBOutlet weak var addDogButtonBackground: UIButton!
    @IBOutlet weak var addDogButton: UIButton!
    
    //When the add button is clicked, runs a series of checks. Makes sure the name and description of the dog is valid, and if so then passes information up chain of view controllers to DogsViewController.
    @IBAction func willAddDog(_ sender: Any) {
        
        let updatedDog = targetDog.copy() as! Dog
        
        do{
            try updatedDog.dogSpecifications.changeDogSpecifications(key: "name", newValue: dogName.text)
            try updatedDog.dogSpecifications.changeDogSpecifications(key: "description", newValue: dogDescription.text)
            
            updatedDog.setEnable(newEnableStatus: dogEnableStatus.isOn)
        }
        catch {
            ErrorProcessor.handleError(sender: Sender(origin: self, localized: self), error: error)
            return
        }
        
        
        do{
            if isUpdating == true{
                try delegate.didUpdateDog(sender: Sender(origin: self, localized: self), formerName: try! targetDog.dogSpecifications.getDogSpecification(key: "name"), updatedDog: updatedDog)
                dismiss(animated: true, completion: nil)
            }
            else{
                try delegate.didAddDog(sender: Sender(origin: self, localized: self), newDog: updatedDog)
                dismiss(animated: true, completion: nil)
            }
        }
        catch {
            ErrorProcessor.handleError(sender: Sender(origin: self, localized: self), error: error)
        }
        
    }
    
    @IBOutlet weak var cancelAddDogButton: UIButton!
    @IBOutlet weak var cancelAddDogButtonBackground: UIButton!
    
    @IBAction func cancelAddDogButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Properties
    
    var dogsRequirementNavigationViewController: DogsRequirementNavigationViewController! = nil
    
    var targetDog = Dog()
    
    var delegate: DogsAddDogViewControllerDelegate! = nil
    
    var isUpdating: Bool = false
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //Utils.presenter = self
    }
    
    private func ibOutletSetup(){
        dogName.delegate = self
        dogDescription.delegate = self
    }
    
    func willInitalize(){
        
        //if isUpdating == true {
            try! dogName.text = targetDog.dogSpecifications.getDogSpecification(key: "name")
            try! dogDescription.text = targetDog.dogSpecifications.getDogSpecification(key: "description")
            dogEnableStatus.isOn = targetDog.getEnable()
            dogsRequirementNavigationViewController.didPassRequirements(sender: Sender(origin: self, localized: self), passedRequirements: targetDog.dogRequirments)
            /*
        }
        else{
            dogName.text = DogConstant.defaultDogSpecificationKeys[0].1
            dogDescription.text = DogConstant.defaultDogSpecificationKeys[1].1
            dogEnableStatus.isOn = DogConstant.defaultEnable
        }
 */
    }
    
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
