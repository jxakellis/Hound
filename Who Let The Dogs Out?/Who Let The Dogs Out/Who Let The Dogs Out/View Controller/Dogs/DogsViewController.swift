//
//  SecondViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 11/4/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsViewControllerDelegate {
    func didAddDog(dogAdded: Dog) throws
    func didRemoveDog(dogRemoved: Dog) throws
    func didUpdateDog(dogUpdated: Dog) throws
}

class DogsViewController: UIViewController, DogsAddDogViewControllerDelegate, DogsMainScreenTableViewControllerDelegate{
    
    //MARK: DogsMainScreenTableViewControllerDelegate
    
    //If a dog was clicked on in DogsMainScreenTableViewController, this function is called with a delegate and allows for the updating of the dogs information
    func didSelectDog(sectionIndexOfDog: Int) {
        
        self.performSegue(withIdentifier: "dogsAddDogViewController", sender: self)
        
        //Conversion of "DogsAddDogViewController" to update mode
        try! dogsAddDogViewController.updateDogTuple = (true, dogManager.dogs[sectionIndexOfDog].dogSpecifications.getDogSpecification(key: "name"))
        dogsAddDogViewController.dog = dogManager.dogs[sectionIndexOfDog]
        dogsAddDogViewController.willInitalize()
        
        dogsAddDogViewController.didPassRequirements(passedRequirements: dogManager.dogs[sectionIndexOfDog].dogRequirments)
        
        dogsAddDogViewController.addDogButton.backgroundColor = .systemGreen
        dogsAddDogViewController.addDogButton.setTitle("Update Dog", for: .normal)
        
    }
    
    //If the dog manager was updated in DogsMainScreenTableViewController, this function is called to reflect that change here with this dogManager
    func didUpdateDogManager(newDogManager: DogManager) {
        dogManager = newDogManager
    }
    
    
    
    //MARK: DogsAddDogViewControllerDelegate
    
    //If a dog was added by the subview, this function is called with a delegate and is incorporated into the dog manager here
    func didAddDog(addedDog: Dog) throws {
        try dogManager.addDog(dogAdded: addedDog)
        dogsMainScreenTableViewController.updateDogManager(newDogManager: self.dogManager)
        //try delegate.didAddDog(dogAdded: addedDog)
    }
    
    //If a dog was updated, its former name (as its name could have been changed) and new dog instance is passed here, matching old dog is found and replaced with new
    func didUpdateDog(formerName: String, updatedDog: Dog) throws {
        try dogManager.changeDog(dogNameToBeChanged: formerName, newDog: updatedDog)
        
        dogsMainScreenTableViewController.updateDogManager(newDogManager: self.dogManager)
    }
    
    //MARK: View IBOutlets and IBActions
    
    @IBOutlet weak var willAddDog: UIButton!
    
    @IBAction func willAddDog(_ sender: Any) {
        
    }
    
    //MARK: Properties
    
    let delegate: DogsViewControllerDelegate! = nil
    
    var dogsMainScreenTableViewController = DogsMainScreenTableViewController()
    
    var dogsAddDogViewController = DogsAddDogViewController()
    
    var dogManager = DogManager()
    
    //MARK: Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defaultDog()
        
        dogsMainScreenTableViewController.updateDogManager(newDogManager: self.dogManager)
        
        willAddDogButtonConfig()
    }
    
    //A default dog for the user
    private func defaultDog(){
        let defaultDog = Dog()
        let defaultRequirement = Requirement()
        
        defaultRequirement.label = "Food"
        defaultRequirement.description = "Feed The Doog"
        defaultRequirement.interval = TimeInterval((3600*5)+(3600*0.75))
        try! defaultDog.dogRequirments.addRequirement(newRequirement: defaultRequirement)
        try! defaultDog.dogSpecifications.changeDogSpecifications(key: "name", newValue: DogConstant.defaultDogSpecificationKeys[0].1)
        try! dogManager.addDog(dogAdded: defaultDog)
    }
    
    //Configures Add Dog button to have rounded corners
    private func willAddDogButtonConfig(){
        willAddDog.layer.cornerRadius = 8.0
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dogsAddDogViewController"{
            dogsAddDogViewController = segue.destination as! DogsAddDogViewController
            dogsAddDogViewController.delegate = self
        }
        if segue.identifier == "dogsMainScreenTableViewController" {
            dogsMainScreenTableViewController = segue.destination as! DogsMainScreenTableViewController
            dogsMainScreenTableViewController.updateDogManager(newDogManager: self.dogManager)
            dogsMainScreenTableViewController.delegate = self
        }
    }
    
    
}

