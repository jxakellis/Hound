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
    @IBOutlet weak var dogEnableStatus: UISwitch!
    
    @IBOutlet weak var embeddedTableView: UIView!
    
    
    @IBOutlet weak var addDogButtonBackground: UIButton!
    @IBOutlet weak var addDogButton: UIButton!
    
    //When the add button is clicked, runs a series of checks. Makes sure the name and description of the dog is valid, and if so then passes information up chain of view controllers to DogsViewController.
    @IBAction func willAddDog(_ sender: Any) {
        
        let updatedDog = targetDog.copy() as! Dog
        
        do{
            try updatedDog.dogTraits.changeDogName(newDogName: dogName.text)
            
            updatedDog.setEnable(newEnableStatus: dogEnableStatus.isOn)
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
    
    @IBOutlet weak var cancelAddDogButton: UIButton!
    @IBOutlet weak var cancelAddDogButtonBackground: UIButton!
    
    @IBAction func cancelAddDogButton(_ sender: Any) {
        self.performSegue(withIdentifier: "unwindToDogsViewController", sender: self)
    }

    //MARK: Properties
    
    var dogsRequirementNavigationViewController: DogsRequirementNavigationViewController! = nil
    
    var targetDog = Dog()
    
    var delegate: DogsAddDogViewControllerDelegate! = nil
    
    var isUpdating: Bool = false
    
    var isAddingRequirement: Bool = false
    
    //MARK: Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupToHideKeyboardOnTapOnView()
        
        self.view.bringSubviewToFront(addDogButtonBackground)
        self.view.bringSubviewToFront(addDogButton)

        self.view.bringSubviewToFront(cancelAddDogButtonBackground)
        self.view.bringSubviewToFront(cancelAddDogButton)
        
        ibOutletSetup()
        
        willInitalize()
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
    }
    
    private func willInitalize(){
        
        dogName.text = targetDog.dogTraits.dogName
        dogEnableStatus.isOn = targetDog.getEnable()
        dogsRequirementNavigationViewController.didPassRequirements(sender: Sender(origin: self, localized: self), passedRequirements: targetDog.dogRequirments)
        
        if isUpdating == true {
            self.navigationItem.title = "Update Dog"
            
            if isAddingRequirement == true {
                dogsRequirementNavigationViewController.dogsRequirementTableViewController.performSegue(withIdentifier: "dogsInstantiateRequirementViewController", sender: self)
            }
            
        }
        else {
            self.navigationItem.title = "Create Dog"
        }
 
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
