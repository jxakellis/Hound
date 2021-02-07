//
//  MainTabBarViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/1/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController, DogManagerControlFlowProtocol, DogsViewControllerDelegate {
    
    
    
    //MARK: DogsViewControllerDelegate
    
    func didUpdateDogManager(newDogManager: DogManager) {
        setDogManager(newDogManager: newDogManager)
    }
    
    //MARK: Master Dog Manager
    
    private var masterDogManager: DogManager = DogManager()
    
    //Get method, returns a copy of dogManager to remove possible editting of dog manager through class reference type
    func getDogManager() -> DogManager {
        return masterDogManager.copy() as! DogManager
    }
    
    //Sets dog manager, when the value of dog manager is changed it not only changes the variable but calls other needed functions to reflect the change
    func setDogManager(newDogManager: DogManager, updateDogManagerDependents: Bool = true, sentFromSuperView: Bool = false){
        masterDogManager = newDogManager.copy() as! DogManager
    }
    
    func updateDogManagerDependents() {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defaultDog()
        
        let dogsViewController = self.viewControllers![1] as! DogsViewController
        
        dogsViewController.delegate = self
        dogsViewController.setDogManager(newDogManager: getDogManager(), sentFromSuperView: true)
        
        // var cal = Calendar(identifier: .gregorian)
    }
    
    //A default dog for the user
    private func defaultDog(){
        let defaultDog = Dog()
        
        let defaultRequirementOne = Requirement()
        defaultRequirementOne.label = "Potty"
        defaultRequirementOne.description = "Take The Dog Out"
        defaultRequirementOne.interval = TimeInterval((3600*3)+(3600*(1/3)))
        try! defaultDog.dogRequirments.addRequirement(newRequirement: defaultRequirementOne)
        
        let defaultRequirementTwo = Requirement()
        defaultRequirementTwo.label = "Food"
        defaultRequirementTwo.description = "Feed The Dog"
        defaultRequirementTwo.interval = TimeInterval((3600*7)+(3600*0.75))
        try! defaultDog.dogRequirments.addRequirement(newRequirement: defaultRequirementTwo)
        
        for i in 0..<DogConstant.defaultDogSpecificationKeys.count{
        try! defaultDog.dogSpecifications.changeDogSpecifications(key: DogConstant.defaultDogSpecificationKeys[i].0, newValue: DogConstant.defaultDogSpecificationKeys[i].1)
        }
        defaultDog.setEnable(newEnableStatus: true)
        
        var sudoDogManager = getDogManager()
        try! sudoDogManager.addDog(dogAdded: defaultDog)
        setDogManager(newDogManager: sudoDogManager)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
