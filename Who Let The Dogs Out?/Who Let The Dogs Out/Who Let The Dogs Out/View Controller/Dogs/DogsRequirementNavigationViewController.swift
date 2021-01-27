//
//  DogsRequirementNavigationViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 1/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class DogsRequirementNavigationViewController: UINavigationController {

    //This delegate is used in order to connect the delegate from the sub table view to the master embedded view, i.e. connect DogsRequirementTableViewController delegate to DogsAddDogViewController
    var passThroughDelegate: DogsRequirementTableViewControllerDelegate! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dogRequirementTableView"{
            let dogsRequirementTableVC = segue.destination as! DogsRequirementTableViewController
            passThroughDelegate = dogsRequirementTableVC.delegate
        }
    }
    

}
