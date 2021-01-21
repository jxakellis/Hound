//
//  DogsAddDogViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 1/19/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class DogsAddDogViewController: UIViewController {

    // var dogRequirementsVC = THEFUTUREVIEWCONTROLLER
    
    @IBOutlet weak var dogName: UITextField!
    @IBOutlet weak var dogDescription: UITextField!
    @IBOutlet weak var dogBreed: UITextField!
    
    @IBAction func addDog(_ sender: Any) {
    }
    
    override func viewDidLoad() {
        dogName.text = "Fido"
        dogDescription.text = "Friendly"
        dogBreed.text = "Golden Retriever"
        super.viewDidLoad()

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
