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
}

class DogsAddDogViewController: UIViewController, AlertError, DogsRequirementNavigationViewControllerDelegate {
    
    //MARK: Requirement Table VC Delegate
    
    //assume all requirements are valid due to the fact that they are all checked and validated through DogsRequirementTableViewController
    func didUpdateRequirements(newRequirementList: [Requirement]) {
        dog.dogRequirments.clearRequirements()
        try! dog.dogRequirments.addRequirement(newRequirements: newRequirementList)
        dogName.text = newRequirementList[0].label
        print(newRequirementList[0].label)
    }
    
    //MARK: Properties
    
    var tempVC = DogsRequirementNavigationViewController()
    
    var dog = Dog()
    
    var delegate: DogsAddDogViewControllerDelegate! = nil
    
    //MARK: View IBConnect
    
    @IBOutlet weak var dogName: UITextField!
    @IBOutlet weak var dogDescription: UITextField!
    @IBOutlet weak var dogBreed: UITextField!
    
    @IBOutlet weak var embeddedTableView: UIView!
    @IBOutlet weak var addDogButton: UIButton!
    
    @IBAction func addDog(_ sender: Any) {
        do{
            try dog.dogSpecifications.changeDogSpecifications(key: "name", newValue: dogName.text)
            try dog.dogSpecifications.changeDogSpecifications(key: "description", newValue: dogDescription.text)
            try dog.dogSpecifications.changeDogSpecifications(key: "breed", newValue: dogBreed.text)
        }
        catch {
            addDogErrorHandle(error: error as! DogSpecificationManagerError)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dogName.text = "Fido"
        dogDescription.text = "Friendly"
        dogBreed.text = "Golden Retriever"
        
        addDogButton.layer.cornerRadius = 8.0
    }
    
    //MARK: private functions
    
    private func addDogErrorHandle(error: DogSpecificationManagerError){
        if case DogSpecificationManagerError.nilKey = error {
            alertForError(message: "Big Time Error! Nil Key for addDog -> dog.dogSpecifications.changeDogSpecifications in DogsAddDogViewController")
        }
        else if case DogSpecificationManagerError.blankKey = error {
            alertForError(message: "Big Time Error! Blank Key for addDog -> dog.dogSpecifications.changeDogSpecifications in DogsAddDogViewController")
        }
        else if case DogSpecificationManagerError.invalidKey = error{
            alertForError(message: "Big Time Error! Invalid Key for addDog -> dog.dogSpecifications.changeDogSpecifications in DogsAddDogViewController")
        }
        else if case DogSpecificationManagerError.nilNewValue("name") = error {
            alertForError(message: "Your dog has an invalid name, try inputting something!")
        }
        else if case DogSpecificationManagerError.blankNewValue("name") = error {
            alertForError(message: "Your dog has a blank name, try inputting something!")
        }
        else if case DogSpecificationManagerError.nilNewValue("description") = error {
            alertForError(message: "Your dog has a invalid description, try inputting something")
        }
        else if case DogSpecificationManagerError.nilNewValue("breed") = error {
            alertForError(message: "Your dog has a invalid breed, try inputting something")
        }
        else {
            alertForError(message: error.localizedDescription)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dogRequirementNavigationController"{
            tempVC = segue.destination as! DogsRequirementNavigationViewController
            tempVC.passThroughDelegate = self
        }
    

}
}
