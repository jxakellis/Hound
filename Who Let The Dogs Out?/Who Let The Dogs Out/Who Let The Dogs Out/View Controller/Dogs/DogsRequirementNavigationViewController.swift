//
//  DogsRequirementNavigationViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsRequirementNavigationViewControllerDelegate {
    func didUpdateRequirements(newRequirementList: [Requirement])
}

class DogsRequirementNavigationViewController: UINavigationController, DogsRequirementTableViewControllerDelegate {
    
    //This delegate is used in order to connect the delegate from the sub table view to the master embedded view, i.e. connect DogsRequirementTableViewController delegate to DogsAddDogViewController
    var passThroughDelegate: DogsRequirementNavigationViewControllerDelegate! = nil
    
    var dogsRequirementTableVC = DogsRequirementTableViewController()
    
    //MARK: DogsRequirementTableViewControllerDelegate
    func didUpdateRequirements(newRequirementList: [Requirement]) {
        print("DRNVC got to core delegate implementation")
        passThroughDelegate.didUpdateRequirements(newRequirementList: newRequirementList)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dogsRequirementTableViewController"{
            print("DRNVC success")
            dogsRequirementTableVC = segue.destination as! DogsRequirementTableViewController
            dogsRequirementTableVC.delegate = self
        }
        print("DRNVC main success")
        dogsRequirementTableVC = segue.destination as! DogsRequirementTableViewController
        dogsRequirementTableVC.delegate = self
    }
    

}
