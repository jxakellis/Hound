//
//  DogsAddDogViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 1/19/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class DogsAddDogViewController: UIViewController, DogsRequirementTableViewControllerDelegate {
    
    //MARK: Requirement Table VC Delegate
    
    //assume all requirements are valid due to the fact that they are all checked and validated through DogsRequirementTableViewController
    func didUpdateRequirements(newRequirementList: [Requirement]) {
        dog.dogRequirments.clearRequirements()
        try! dog.dogRequirments.addRequirement(newRequirements: newRequirementList)
    }
    
    //MARK: Properties
    
    var dog = Dog()
    
    //MARK: View IBConnect
    
    @IBOutlet weak var dogName: UITextField!
    @IBOutlet weak var dogDescription: UITextField!
    @IBOutlet weak var dogBreed: UITextField!
    
    @IBOutlet weak var embeddedTableView: UIView!
    @IBOutlet weak var addDogButton: UIButton!
    
    @IBAction func addDog(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dogName.text = "Fido"
        dogDescription.text = "Friendly"
        dogBreed.text = "Golden Retriever"
        
        addDogButton.layer.cornerRadius = 8.0
        // Do any additional setup after loading the view.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dogRequirementNavigationController"{
            //dogRequirementsVC = segue.destination as! THEFUTUREVIEWCONTROLLER
            //dogRequirementsVC.delegate = self
        }
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    

}
