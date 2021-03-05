//
//  HomeViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/5/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

/*
protocol HomeViewControllerDelegate {
    func didLogTimers(sender: AnyObject, loggedRequirements: [(String, Requirement)])
}
 */

class HomeViewController: UIViewController, DogManagerControlFlowProtocol, HomeMainScreenTableViewControllerDelegate {
    
    //MARK: HomeMainScreenTableViewControllerDelegate
    
    func didSelectOption() {
        self.willToggleLogState(sender: self, newSelectionControlState: false)
    }
    
    //MARK: DogManagerControlFlowProtocol
    
    private var dogManager: DogManager = DogManager()
    
    func getDogManager() -> DogManager {
        return dogManager.copy() as! DogManager
    }
    
    func setDogManager(newDogManager: DogManager, sender: AnyObject?) {
        dogManager = newDogManager.copy() as! DogManager
        
        if sender is MainTabBarViewController {
            homeMainScreenTableViewController.setDogManager(newDogManager: getDogManager(), sender: self)
        }
    }
    
    func updateDogManagerDependents() {
        //
    }
    
    //MARK: IBOutlet and IBAction
    
    @IBOutlet weak var willLog: UIButton!
    @IBOutlet weak var willLogBackground: UIButton!
    
    @IBOutlet weak var cancelWillLog: UIButton!
    @IBOutlet weak var cancelWillLogBackground: UIButton!
    
    @IBOutlet weak var willLogLabel: UILabel!
    
    @IBAction func willLog(_ sender: Any) {
        
        //off to on
        if logState == false {
            willToggleLogState(sender: self, newSelectionControlState: true)
        }
        //on to off
        else if logState == true {
            willToggleLogState(sender: self, newSelectionControlState: false)
        }
    }
    
    @IBAction func cancelWillLog(_ sender: Any) {
        willToggleLogState(sender: self, newSelectionControlState: false)
    }
    
    //MARK: Properties
    
    //var delegate: HomeViewControllerDelegate! = nil
    
    var homeMainScreenTableViewController = HomeMainScreenTableViewController()
    
    var logState: Bool = false
    
    //MARK: Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.bringSubviewToFront(willLogBackground)
        self.view.bringSubviewToFront(willLog)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if TimingManager.activeTimers == 0 {
            willToggleLogState(sender: self, newSelectionControlState: false)
            
                self.willLog.isHidden = true
                self.willLog.isEnabled = false
                self.willLogBackground.isHidden = true
                self.willLogBackground.isEnabled = false
            
        }
        else {
                self.willLog.isHidden = false
                self.willLog.isEnabled = true
                self.willLogBackground.isHidden = false
                self.willLogBackground.isEnabled = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        willToggleLogState(sender: self, newSelectionControlState: false)
    }
    
    ///Toggles all corrosponding information to the specified newState: Bool, sender is the VC which called this information
    private func willToggleLogState(sender: AnyObject, newSelectionControlState: Bool){
        if newSelectionControlState == true && TimingManager.activeTimers > 0 {
            //Visual element in current VC management
           
            self.cancelWillLog.isEnabled = true
            self.cancelWillLog.isHidden = false
            self.cancelWillLogBackground.isEnabled = true
            self.cancelWillLogBackground.isHidden = false
            self.willLogLabel.isHidden = false
            self.willLog.tintColor = UIColor.systemGreen
            
            if !(sender is HomeMainScreenTableViewController) {
                homeMainScreenTableViewController.logState = true
                homeMainScreenTableViewController.tableView.reloadData()
            }
            
            logState = true
        }
        else if newSelectionControlState == false {
            //Visual element in current VC management
            self.cancelWillLog.isEnabled = false
            self.cancelWillLog.isHidden = true
            self.cancelWillLogBackground.isEnabled = false
            self.cancelWillLog.isHidden = true
            self.willLogLabel.isHidden = true
                self.willLog.tintColor = UIColor.link
            
            if !(sender is HomeMainScreenTableViewController) {
                homeMainScreenTableViewController.logState = false
                homeMainScreenTableViewController.tableView.reloadData()
            }
            
            logState = false
        }
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "homeMainScreenTableViewController"{
            homeMainScreenTableViewController = segue.destination as! HomeMainScreenTableViewController
            homeMainScreenTableViewController.setDogManager(newDogManager: self.getDogManager(), sender: self)
            homeMainScreenTableViewController.delegate = self
        }
        
    }
    
    
}
