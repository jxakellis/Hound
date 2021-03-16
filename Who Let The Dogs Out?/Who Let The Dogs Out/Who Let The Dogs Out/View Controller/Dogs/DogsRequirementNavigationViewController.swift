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
    
    //MARK: Properties
    
    //This delegate is used in order to connect the delegate from the sub table view to the master embedded view, i.e. connect DogsRequirementTableViewController delegate to DogsAddDogViewController
    var passThroughDelegate: DogsRequirementNavigationViewControllerDelegate! = nil
    
    //MARK: DogsRequirementTableViewControllerDelegate
    
    func didUpdateRequirements(newRequirementList: [Requirement]) {
        passThroughDelegate.didUpdateRequirements(newRequirementList: newRequirementList)
    }
    
    var dogsRequirementTableViewController: DogsRequirementTableViewController! = nil
    
    //MARK: Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Sets DogsRequirementTableViewController delegate to self, this is required to pass through the data to DogsAddDogViewController as this navigation controller is in the way.
        dogsRequirementTableViewController = self.viewControllers[self.viewControllers.count-1] as? DogsRequirementTableViewController
        dogsRequirementTableViewController.delegate = self
    }
    
    //MARK: DogsAddDogViewController
    
    //Called by superview to pass down new requirements to subview, used when editting a dog
    func didPassRequirements(sender: Sender, passedRequirements: RequirementManager){
        dogsRequirementTableViewController.setRequirementManager(sender: Sender(origin: sender, localized: self), newRequirementManager: passedRequirements)
    }
}
