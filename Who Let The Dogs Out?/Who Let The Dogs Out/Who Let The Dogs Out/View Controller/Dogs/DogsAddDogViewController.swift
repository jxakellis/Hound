//
//  DogsAddDogViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 1/19/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsAddDogViewControllerDelegate{
    func didAddDog(addedDog: Dog) throws
    func didUpdateDog(formerName: String, updatedDog: Dog) throws
}

class DogsAddDogViewController: UIViewController, AlertError, DogsRequirementNavigationViewControllerDelegate {
    
    //MARK: Requirement Table VC Delegate
    
    //assume all requirements are valid due to the fact that they are all checked and validated through DogsRequirementTableViewController
    func didUpdateRequirements(newRequirementList: [Requirement]) {
        dog.dogRequirments.clearRequirements()
        try! dog.dogRequirments.addRequirement(newRequirements: newRequirementList)
    }
    
    //MARK: Properties
    
    var dogsRequirementNavigationViewController = DogsRequirementNavigationViewController()
    
    var dog = Dog()
    
    var delegate: DogsAddDogViewControllerDelegate! = nil
    
    var updateDogTuple: (Bool, String) = (false, "")
    
    //MARK: View IBOutlets and IBActions
    
    @IBOutlet weak var dogName: UITextField!
    @IBOutlet weak var dogDescription: UITextField!
    @IBOutlet weak var dogBreed: UITextField!
    
    @IBOutlet weak var embeddedTableView: UIView!
    @IBOutlet weak var addDogButton: UIButton!
    
    //When the add button is clicked, runs a series of checks. Makes sure the name, description, and breed of the dog is valid, and if so then passes information up chain of view controllers to DogsViewController.
    @IBAction func addDog(_ sender: Any) {
        
        do{
            try dog.dogSpecifications.changeDogSpecifications(key: "name", newValue: dogName.text)
            try dog.dogSpecifications.changeDogSpecifications(key: "description", newValue: dogDescription.text)
            try dog.dogSpecifications.changeDogSpecifications(key: "breed", newValue: dogBreed.text)
        }
        catch {
            ErrorProcessor.handleError(error: error, classCalledFrom: self)
        }
        do{
            
            if updateDogTuple.0 == true{
                try delegate.didUpdateDog(formerName: updateDogTuple.1, updatedDog: dog)
                dismiss(animated: true, completion: nil)
            }
            else{
                try delegate.didAddDog(addedDog: dog)
                dismiss(animated: true, completion: nil)
            }
        }
        catch {
            ErrorProcessor.handleError(error: error, classCalledFrom: self)
        }
    }
    
    //MARK: Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dogName.text = "Fido"
        dogDescription.text = "Friendly"
        dogBreed.text = "Golden Retriever"
        
        addDogButton.layer.cornerRadius = 8.0
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dogRequirementNavigationController"{
            dogsRequirementNavigationViewController = segue.destination as! DogsRequirementNavigationViewController
            dogsRequirementNavigationViewController.passThroughDelegate = self
        }
        
        
    }
}