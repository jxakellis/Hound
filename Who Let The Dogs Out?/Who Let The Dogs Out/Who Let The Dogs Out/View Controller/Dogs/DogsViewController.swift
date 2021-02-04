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

class DogsViewController: UIViewController, DogsAddDogViewControllerDelegate {
    
    
    
    let delegate: DogsViewControllerDelegate! = nil
    
    //MARK: DogsAddDogViewControllerDelegate
    
    func didAddDog(addedDog: Dog) throws {
        try dogManager.addDog(dogAdded: addedDog)
        dogsMainScreenTableViewController.updateDogManager(newDogManager: self.dogManager)
        //try delegate.didAddDog(dogAdded: addedDog)
    }
    
    func didUpdateDog(formerName: String, updatedDog: Dog) throws {
        var recoveryDog: Dog {
            get{
                for i in 0..<dogManager.dogs.count{
                    if try! dogManager.dogs[i].dogSpecifications.getDogSpecification(key: "name") == formerName{
                        return dogManager.dogs[i]
                    }
                }
                return Dog()
            }
        }
        try dogManager.removeDog(name: formerName)
        do{
            try dogManager.addDog(dogAdded: updatedDog)
        }
        catch{
            try! dogManager.addDog(dogAdded: recoveryDog)
        }
        dogsMainScreenTableViewController.updateDogManager(newDogManager: self.dogManager)
    }
    
    //MARK: View IBOutlets and IBActions
    
   @IBOutlet weak var willAddDog: UIButton!
    
   @IBAction func willAddDog(_ sender: Any) {
    
    }
    
    //MARK: Properties
    
    var dogsMainScreenTableViewController = DogsMainScreenTableViewController()
    
    var dogsAddDogViewController = DogsAddDogViewController()
    
    var dogManager = DogManager()
    
    //MARK: Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaultDog = Dog()
        let defaultRequirement = Requirement()
        defaultRequirement.label = "Food"
        defaultRequirement.description = "Feed The Doog"
        defaultRequirement.interval = TimeInterval((3600*5)+(3600*0.75))
        try! defaultDog.dogRequirments.addRequirement(newRequirement: defaultRequirement)
        try! defaultDog.dogSpecifications.changeDogSpecifications(key: "name", newValue: DogConstant.defaultDogSpecificationKeys[0].1)
        try! dogManager.addDog(dogAdded: defaultDog)
        // Do any additional setup after loading the view.
        addDogButtonConfig()
    }
    
    func addDogButtonConfig(){
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
            dogsMainScreenTableViewController.superDogsViewController = self
        }
    }
    
    
}

