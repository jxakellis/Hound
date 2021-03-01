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
            /*
            if self.homeMainScreenTableViewController.tableView.indexPathsForSelectedRows != nil{
                var requirementsLogged: [(String, Requirement)] = []
                for indexPath in self.homeMainScreenTableViewController.tableView.indexPathsForSelectedRows! {
                    let cell = homeMainScreenTableViewController.tableView.cellForRow(at: indexPath) as! HomeMainScreenTableViewCellDogRequirementDisplay
                    requirementsLogged.append((cell.dogName.text!, cell.requirementSource))
                }
                delegate.didLogTimers(sender: self, loggedRequirements: requirementsLogged)
            }
            */
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
            willLog.isHidden = true
            willLog.isEnabled = false
            willLogBackground.isHidden = true
            willLogBackground.isEnabled = false
        }
        else {
            willLog.isHidden = false
            willLog.isEnabled = true
            willLogBackground.isHidden = false
            willLogBackground.isEnabled = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        willToggleLogState(sender: self, newSelectionControlState: false)
    }
    
    ///Toggles all corrosponding information to the specified newState: Bool, sender is the VC which called this information
    private func willToggleLogState(sender: AnyObject, newSelectionControlState: Bool){
        if newSelectionControlState == true && TimingManager.activeTimers > 0 {
            //Visual element in current VC management
            willLog.tintColor = UIColor.systemGreen
            cancelWillLog.isEnabled = true
            cancelWillLog.isHidden = false
            cancelWillLogBackground.isEnabled = true
            cancelWillLogBackground.isHidden = false
            willLogLabel.isHidden = false
            
            if !(sender is HomeMainScreenTableViewController) {
                homeMainScreenTableViewController.logState = true
                homeMainScreenTableViewController.tableView.reloadData()
            }
            
            logState = true
        }
        else if newSelectionControlState == false {
            //Visual element in current VC management
            willLog.tintColor = UIColor.link
            cancelWillLog.isEnabled = false
            cancelWillLog.isHidden = true
            cancelWillLogBackground.isEnabled = false
            cancelWillLog.isHidden = true
            willLogLabel.isHidden = true
            
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
