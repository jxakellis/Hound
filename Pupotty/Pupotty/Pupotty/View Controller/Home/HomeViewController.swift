//
//  HomeViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/5/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, DogManagerControlFlowProtocol {
    
    
    //MARK: DogManagerControlFlowProtocol
    
    private var dogManager: DogManager = DogManager()
    
    func getDogManager() -> DogManager {
        //DogManagerEfficencyImprovement return dogManager.copy() as! DogManager
        return dogManager
    }
    
    func setDogManager(sender: Sender, newDogManager: DogManager) {
        //DogManagerEfficencyImprovement dogManager = newDogManager.copy() as! DogManager
        dogManager = newDogManager
        
        if sender.localized is MainTabBarViewController {
            homeMainScreenTableViewController.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
        }
        
        if sender.origin is TimingManager.Type || sender.origin is TimingManager {
            //controlRefresh(sender: Sender(origin: sender, localized: self), animated: true)
        }
    }
    
    func updateDogManagerDependents() {
        //
    }
    
    //MARK: IB
    
    
    @IBAction func didClickSettings(_ sender: Any) {
        self.tabBarController!.selectedIndex = 3
    }
    
    //MARK: Properties
    
    var homeMainScreenTableViewController = HomeMainScreenTableViewController()
    
    //MARK: Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utils.presenter = self
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "homeMainScreenTableViewController"{
            homeMainScreenTableViewController = segue.destination as! HomeMainScreenTableViewController
            homeMainScreenTableViewController.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: self.getDogManager())
        }
        
    }
    
    
}
