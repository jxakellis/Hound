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

class DogsViewController: UIViewController, DogManagerControlFlowProtocol, DogsAddDogViewControllerDelegate, DogsMainScreenTableViewControllerDelegate{
    
    //MARK: DogsMainScreenTableViewControllerDelegate
    
    //If a dog was clicked on in DogsMainScreenTableViewController, this function is called with a delegate and allows for the updating of the dogs information
    func didSelectDog(sectionIndexOfDog: Int) {
        
        self.performSegue(withIdentifier: "dogsAddDogViewController", sender: self)
        
        //Conversion of "DogsAddDogViewController" to update mode
        try! dogsAddDogViewController.updateDogTuple = (true, getDogManager().dogs[sectionIndexOfDog].dogSpecifications.getDogSpecification(key: "name"))
        dogsAddDogViewController.dog = getDogManager().dogs[sectionIndexOfDog]
        dogsAddDogViewController.willInitalize()
        
        dogsAddDogViewController.didPassRequirements(passedRequirements: getDogManager().dogs[sectionIndexOfDog].dogRequirments)
        
        dogsAddDogViewController.addDogButton.setTitle("Update Dog", for: .normal)
        
    }
    
    //If the dog manager was updated in DogsMainScreenTableViewController, this function is called to reflect that change here with this dogManager
    func didUpdateDogManager(newDogManager: DogManager, sender: AnyObject?) {
        setDogManager(newDogManager: newDogManager, sender: sender)
    }
    
    //MARK: DogsAddDogViewControllerDelegate
    
    //If a dog was added by the subview, this function is called with a delegate and is incorporated into the dog manager here
    func didAddDog(addedDog: Dog) throws {
        var sudoDogManager = getDogManager()
        try sudoDogManager.addDog(dogAdded: addedDog)
        setDogManager(newDogManager: sudoDogManager, sender: DogsAddDogViewController())
        //try delegate.didAddDog(dogAdded: addedDog)
    }
    
    //If a dog was updated, its former name (as its name could have been changed) and new dog instance is passed here, matching old dog is found and replaced with new
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
    
    //MARK: Dog Manager
    
    //seperation of church and state or something, this is mainly so when dogManager is changed, it is all routed through these two functions and the necessary action is taken.
    private var dogManager = DogManager()
    
    //Get method, returns a copy of dogManager to remove possible editting of dog manager through class reference type
    func getDogManager() -> DogManager {
        return dogManager.copy() as! DogManager
    }
    
    //Sets dog manager, when the value of dog manager is changed it not only changes the variable but calls other needed functions to reflect the change
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
            delegate.didUpdateDogManager(newDogManager: getDogManager(), sender: sender)
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
            dogsAddDogViewController.delegate = self
        }
        if segue.identifier == "dogsMainScreenTableViewController" {
            dogsMainScreenTableViewController = segue.destination as! DogsMainScreenTableViewController
            dogsMainScreenTableViewController.delegate = self
        }
    }
    
    
}

