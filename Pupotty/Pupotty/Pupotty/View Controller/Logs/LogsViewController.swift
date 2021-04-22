//
//  LogsViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 4/17/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class LogsViewController: UIViewController, DogManagerControlFlowProtocol {
    
    
    //MARK: DogManagerControlFlowProtocol
    
    private var dogManager: DogManager = DogManager()
    
    func getDogManager() -> DogManager {
        //DogManagerEfficencyImprovement return dogManager.copy() as! DogManager
        return dogManager
    }
    
    func setDogManager(sender: Sender, newDogManager: DogManager) {
        //DogManagerEfficencyImprovement dogManager = newDogManager.copy() as! DogManager
        dogManager = newDogManager
        
        if sender.localized is MainTabBarViewController{
            logsMainScreenTableViewController?.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: dogManager)
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
    
    var logsMainScreenTableViewController: LogsMainScreenTableViewController? = nil
    
    //MARK: Main

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utils.presenter = self
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logsMainScreenTableViewController"{
            logsMainScreenTableViewController = segue.destination as? LogsMainScreenTableViewController
            logsMainScreenTableViewController!.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: getDogManager())
        }
    }
    

}
