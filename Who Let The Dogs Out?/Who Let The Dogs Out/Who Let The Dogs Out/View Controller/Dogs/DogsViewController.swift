//
//  SecondViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 11/4/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

class DogsViewController: UIViewController, DogsAddDogViewControllerDelegate {
    
    //MARK: DogsAddDogViewControllerDelegate
    
    func didAddDog(addedDog: Dog) throws {
        try dogManager.addDog(dogAdded: addedDog)
    }
    
    //MARK: View IBOutlets and IBActions
    
    @IBOutlet weak var willAddDog: UIButton!
    
    @IBAction func willAddDog(_ sender: Any) {
        
    }
    
    //MARK: Properties
    
    var dogsAddDogViewController = DogsAddDogViewController()
    
    var dogManager = DogManager()
    
    //MARK: Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let defaultDog = Dog()
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
    }
    

}

