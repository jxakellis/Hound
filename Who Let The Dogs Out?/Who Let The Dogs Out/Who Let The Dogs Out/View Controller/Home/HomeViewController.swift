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
    
    func didSelectOption(sender: Sender) {
        if TimingManager.activeTimers == nil || TimingManager.activeTimers == 0 {
            willToggleLogState(sender: sender, newSelectionControlState: nil, animated: true)
        }
        else {
            willToggleLogState(sender: sender, newSelectionControlState: false, animated: true)
        }
    }
    
    //MARK: DogManagerControlFlowProtocol
    
    private var dogManager: DogManager = DogManager()
    
    func getDogManager() -> DogManager {
        return dogManager.copy() as! DogManager
    }
    
    func setDogManager(sender: Sender, newDogManager: DogManager) {
        dogManager = newDogManager.copy() as! DogManager
        
        if sender.localized is MainTabBarViewController {
            homeMainScreenTableViewController.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
        }
        
        if sender.origin is TimingManager.Type || sender.origin is TimingManager {
            controlRefresh(sender: Sender(origin: sender, localized: self), animated: true)
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
            willToggleLogState(sender: Sender(origin: self, localized: self), newSelectionControlState: true)
        }
        //on to off
        else if logState == true {
            willToggleLogState(sender: Sender(origin: self, localized: self), newSelectionControlState: false)
        }
    }
    
    @IBAction func cancelWillLog(_ sender: Any) {
        willToggleLogState(sender: Sender(origin: self, localized: self), newSelectionControlState: false)
    }
    
    //MARK: Properties
    
    //var delegate: HomeViewControllerDelegate! = nil
    
    var homeMainScreenTableViewController = HomeMainScreenTableViewController()
    
    var logState: Bool = false
    
    //MARK: Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.willLogLabel.isEnabled = false
        self.willLogLabel.isHidden = true
        
        self.view.bringSubviewToFront(willLogBackground)
        self.view.bringSubviewToFront(willLog)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        controlRefresh(sender: Sender(origin: self, localized: self), animated: false)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        willToggleLogState(sender: Sender(origin: self, localized: self), newSelectionControlState: false, animated: false)
    }
    
    ///Toggles all corrosponding information to the specified newState: Bool, sender is the VC which called this information
    private func willToggleLogState(sender: Sender, newSelectionControlState: Bool?, animated: Bool = true){
        if newSelectionControlState == nil {
            if logState == true {
                
                if animated == true{
                    let originCWL = cancelWillLog.frame.origin
                    let originCWLB = cancelWillLogBackground.frame.origin
                    
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: 0.35) {
                            self.cancelWillLog.frame = CGRect(origin: self.willLog.frame.origin, size: self.cancelWillLog.frame.size)
                            self.cancelWillLogBackground.frame = CGRect(origin: self.willLogBackground.frame.origin, size: self.cancelWillLogBackground.frame.size)
                            self.willLog.tintColor = UIColor.link
                        } completion: { (completed) in
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                                self.toggleWillLogVisibility(isHidden: true)
                                self.toggleCancelWillLogVisibility(isHidden: true)
                                self.cancelWillLog.frame = CGRect(origin: originCWL, size: self.cancelWillLog.frame.size)
                                self.cancelWillLogBackground.frame = CGRect(origin: originCWLB, size: self.cancelWillLogBackground.frame.size)
                                
                            }
                            
                        }
                    }
                    
                }
                else if animated == false {
                    toggleWillLogVisibility(isHidden: true)
                    toggleCancelWillLogVisibility(isHidden: true)
                    self.willLog.tintColor = UIColor.link
                }
            }
            else if logState == false{
                if animated == true {
                    toggleWillLogVisibility(isHidden: true)
                    toggleCancelWillLogVisibility(isHidden: true)
                }
                else if animated == false{
                    toggleWillLogVisibility(isHidden: true)
                    toggleCancelWillLogVisibility(isHidden: true)
                }
            }
            
            logState = false
        }
        else if newSelectionControlState! == true && TimingManager.activeTimers != nil && TimingManager.activeTimers! > 0 {
            //Visual element in current VC management
            let originCWL = cancelWillLog.frame.origin
            let originCWLB = cancelWillLogBackground.frame.origin
            
            cancelWillLog.frame = CGRect(origin: willLog.frame.origin, size: cancelWillLog.frame.size)
            cancelWillLogBackground.frame = CGRect(origin: willLogBackground.frame.origin, size: cancelWillLogBackground.frame.size)
            
            toggleCancelWillLogVisibility(isHidden: false)
            
            UIView.animate(withDuration: 0.35) {
                self.cancelWillLog.frame = CGRect(origin: originCWL, size: self.cancelWillLog.frame.size)
                self.cancelWillLogBackground.frame = CGRect(origin: originCWLB, size: self.cancelWillLogBackground.frame.size)
                self.willLog.tintColor = UIColor.systemGreen
            }
            
            logState = true
            toggleCancelWillLogTouch(isTouchEnabled: true)
        }
        else if newSelectionControlState! == false {
            //Visual element in current VC management
            toggleCancelWillLogTouch(isTouchEnabled: false)
            if animated == true {
                let originCWL = cancelWillLog.frame.origin
                let originCWLB = cancelWillLogBackground.frame.origin
                
                
                UIView.animate(withDuration: 0.35) {
                    self.cancelWillLog.frame = CGRect(origin: self.willLog.frame.origin, size: self.cancelWillLog.frame.size)
                    self.cancelWillLogBackground.frame = CGRect(origin: self.willLogBackground.frame.origin, size: self.cancelWillLogBackground.frame.size)
                    self.willLog.tintColor = UIColor.link
                    
                } completion: { (completed) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.18) {
                        self.toggleCancelWillLogVisibility(isHidden: true)
                        //reset button to original position but it is now hidden.
                        self.cancelWillLog.frame = CGRect(origin: originCWL, size: self.cancelWillLog.frame.size)
                        self.cancelWillLogBackground.frame = CGRect(origin: originCWLB, size: self.cancelWillLogBackground.frame.size)
                    }
                }
            }
            else if animated == false {
                self.toggleCancelWillLogVisibility(isHidden: true)
                self.willLog.tintColor = UIColor.link
            }
            
            logState = false
        }
        
        if !(sender.localized is HomeMainScreenTableViewController) {
            homeMainScreenTableViewController.logState = self.logState
            homeMainScreenTableViewController.reloadTable()
        }
    }
    
    ///Refreshes the buttons to reflect the data present
    func controlRefresh(sender: Sender, animated: Bool){
        if TimingManager.activeTimers == nil || TimingManager.activeTimers == 0 {
            willToggleLogState(sender: Sender(origin: sender, localized: self), newSelectionControlState: nil, animated: animated)
        }
        else {
            toggleWillLogVisibility(isHidden: false)
            toggleWillLogTouch(isTouchEnabled: true)
        }
    }
    
    private func toggleWillLogVisibility(isHidden: Bool){
        if isHidden == true {
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
    
    private func toggleWillLogTouch(isTouchEnabled: Bool){
        willLog.isUserInteractionEnabled = isTouchEnabled
    }
    
    private func toggleCancelWillLogVisibility(isHidden: Bool){
        if isHidden == true {
            self.cancelWillLog.isHidden = true
            self.cancelWillLog.isEnabled = false
            self.cancelWillLogBackground.isHidden = true
            self.cancelWillLogBackground.isEnabled = false
        }
        else {
            self.cancelWillLog.isHidden = false
            self.cancelWillLog.isEnabled = true
            self.cancelWillLogBackground.isHidden = false
            self.cancelWillLogBackground.isEnabled = true
        }
    }
    
    private func toggleCancelWillLogTouch(isTouchEnabled: Bool){
        cancelWillLog.isUserInteractionEnabled = isTouchEnabled
    }
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "homeMainScreenTableViewController"{
            homeMainScreenTableViewController = segue.destination as! HomeMainScreenTableViewController
            homeMainScreenTableViewController.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: self.getDogManager())
            homeMainScreenTableViewController.delegate = self
        }
        
    }
    
    
}
