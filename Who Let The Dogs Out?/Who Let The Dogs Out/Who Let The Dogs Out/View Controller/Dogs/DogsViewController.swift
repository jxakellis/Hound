//
//  SecondViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 11/4/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsViewControllerDelegate {
    func didUpdateDogManager(newDogManager: DogManager, sender: AnyObject?)
}

class DogsViewController: UIViewController, DogManagerControlFlowProtocol, DogsAddDogViewControllerDelegate, DogsMainScreenTableViewControllerDelegate, DogsUpdateRequirementViewControllerDelegate{
    
    //MARK: DogsUpdateRequirementViewControllerDelegate
    
    func didUpdateRequirement(parentDogName: String, formerName: String, updatedRequirement: Requirement) throws {
        let sudoDogManager = getDogManager()
        
        try sudoDogManager.findDog(dogName: parentDogName).dogRequirments.changeRequirement(requirementToBeChanged: formerName, newRequirement: updatedRequirement)
        
        setDogManager(newDogManager: sudoDogManager, sender: DogsUpdateRequirementViewController())
    }
    
    //MARK: DogsMainScreenTableViewControllerDelegate
    
    ///If a dog was clicked on in DogsMainScreenTableViewController, this function is called with a delegate and allows for the updating of the dogs information
    func didSelectDog(indexPathSection dogIndex: Int) {
        
        self.performSegue(withIdentifier: "dogsAddDogViewController", sender: self)
        
        //Conversion of "DogsAddDogViewController" to update mode
        try! dogsAddDogViewController.updateDogTuple = (true, getDogManager().dogs[dogIndex].dogSpecifications.getDogSpecification(key: "name"))
        dogsAddDogViewController.dog = getDogManager().dogs[dogIndex]
        dogsAddDogViewController.willInitalize()
        
        //chaged to handle locally
        //dogsAddDogViewController.didPassRequirements(passedRequirements: getDogManager().dogs[dogIndex].dogRequirments)
        
        dogsAddDogViewController.addDogButton.setTitle("Update Dog", for: .normal)
        
    }
    
    ///If a requirement was clicked on in DogsMainScreenTableViewController, this function is called with a delegate and allows for the updating of the requirements information
    func didSelectRequirement(indexPathSection dogIndex: Int, indexPathRow requirementIndex: Int) {
        self.performSegue(withIdentifier: "dogsUpdateRequirementViewController", sender: DogsMainScreenTableViewController())
        
        dogsUpdateRequirementViewController.targetRequirement = getDogManager().dogs[dogIndex].dogRequirments.requirements[requirementIndex]
        try! dogsUpdateRequirementViewController.parentDogName = getDogManager().dogs[dogIndex].dogSpecifications.getDogSpecification(key: "name")
    }
    
    ///If the dog manager was updated in DogsMainScreenTableViewController, this function is called to reflect that change here with this dogManager
    func didUpdateDogManager(newDogManager: DogManager, sender: AnyObject?) {
        setDogManager(newDogManager: newDogManager, sender: sender)
    }
    
    //MARK: DogsAddDogViewControllerDelegate
    
    ///If a dog was added by the subview, this function is called with a delegate and is incorporated into the dog manager here
    func didAddDog(newDog: Dog) throws {
        
        //This makes it so when a dog is added all of its requirements start counting down at the same time (b/c same last execution) instead counting down from when the requirement was added to the dog.
        for requirementIndex in 0..<newDog.dogRequirments.requirements.count{
            newDog.dogRequirments.requirements[requirementIndex].changeLastExecution(newLastExecution: Date())
        }
        
        var sudoDogManager = getDogManager()
        try sudoDogManager.addDog(dogAdded: newDog)
        setDogManager(newDogManager: sudoDogManager, sender: DogsAddDogViewController())
        //try delegate.didAddDog(dogAdded: addedDog)
    }
    
    ///If a dog was updated, its former name (as its name could have been changed) and new dog instance is passed here, matching old dog is found and replaced with new
    func didUpdateDog(formerName: String, updatedDog: Dog) throws {
        var sudoDogManager = getDogManager()
        try sudoDogManager.changeDog(dogNameToBeChanged: formerName, newDog: updatedDog)
        setDogManager(newDogManager: sudoDogManager, sender: DogsAddDogViewController())
    }
    
    //MARK: View IBOutlets and IBActions
    
    @IBOutlet weak var willAddDog: UIButton!
    
    @IBOutlet weak var willAddDogBackground: UIButton!
    
    //MARK: Properties
    
    var delegate: DogsViewControllerDelegate! = nil
    
    var dogsMainScreenTableViewController = DogsMainScreenTableViewController()
    
    var dogsAddDogViewController = DogsAddDogViewController()
    
    var dogsUpdateRequirementViewController = DogsUpdateRequirementViewController()
    
    //MARK: Dog Manager
    
    private var dogManager = DogManager()
    
    func getDogManager() -> DogManager {
        return dogManager.copy() as! DogManager
    }
    
    func setDogManager(newDogManager: DogManager, sender: AnyObject?) {
        dogManager = newDogManager.copy() as! DogManager
        
        //possible senders
        //DogsMainScreenTableViewController
        //DogsAddDogViewController
        //MainTabBarViewController
        
        if !(sender is DogsMainScreenTableViewController) {
            self.updateDogManagerDependents()
        }
        
        if !(sender is MainTabBarViewController)  {
            delegate.didUpdateDogManager(newDogManager: getDogManager(), sender: self)
        }
        
    }
    
    //Updates different visual aspects to reflect data change of dogManager
    func updateDogManagerDependents(){
        dogsMainScreenTableViewController.setDogManager(newDogManager: getDogManager(), sender: self)
    }
    
    //MARK: Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateDogManagerDependents()
        self.view.bringSubviewToFront(willAddDogBackground)
        self.view.bringSubviewToFront(willAddDog)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dogsAddDogViewController"{
            dogsAddDogViewController = segue.destination as! DogsAddDogViewController
            dogsAddDogViewController.modalPresentationStyle = .fullScreen
            dogsAddDogViewController.delegate = self
        }
        if segue.identifier == "dogsMainScreenTableViewController" {
            dogsMainScreenTableViewController = segue.destination as! DogsMainScreenTableViewController
            dogsMainScreenTableViewController.delegate = self
        }
        if segue.identifier == "dogsUpdateRequirementViewController" {
            dogsUpdateRequirementViewController = segue.destination as! DogsUpdateRequirementViewController
            dogsUpdateRequirementViewController.modalPresentationStyle = .fullScreen
            dogsUpdateRequirementViewController.delegate = self
        }
    }
    
    
}

