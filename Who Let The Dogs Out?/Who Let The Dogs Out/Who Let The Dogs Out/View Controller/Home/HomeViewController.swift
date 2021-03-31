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
        if TimingManager.enabledTimersCount == nil || TimingManager.enabledTimersCount == 0 {
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
    
    //MARK: IB
    
    @IBOutlet weak var willLog: UIButton!
    @IBOutlet weak var willLogBackground: UIButton!
    
    @IBOutlet weak var cancelWillLog: UIButton!
    @IBOutlet weak var cancelWillLogBackground: UIButton!
    
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
        
        self.view.bringSubviewToFront(cancelWillLogBackground)
        self.view.bringSubviewToFront(cancelWillLog)
        
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
        toggleCancelWillLogTouch(isTouchEnabled: false)
        toggleWillLogTouch(isTouchEnabled: false)
        
        if newSelectionControlState == nil {
            if logState == true {
                
                if animated == true{
                    let originCWL = cancelWillLog.frame.origin
                    let originCWLB = cancelWillLogBackground.frame.origin
                    
                    DispatchQueue.main.async {
                        UIView.animate(withDuration: AnimationConstant.HomeLogStateAnimate.rawValue) {
                            self.cancelWillLog.frame = CGRect(origin: self.willLog.frame.origin, size: self.cancelWillLog.frame.size)
                            self.cancelWillLogBackground.frame = CGRect(origin: self.willLogBackground.frame.origin, size: self.cancelWillLogBackground.frame.size)
                            self.willLog.tintColor = UIColor.link
                        } completion: { (completed) in
                            DispatchQueue.main.asyncAfter(deadline: .now() + AnimationConstant.HomeLogStateDisappearDelay.rawValue) {
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
        else if newSelectionControlState! == true && TimingManager.enabledTimersCount != nil && TimingManager.enabledTimersCount! > 0 {
            //Visual element in current VC management
            let originCWL = cancelWillLog.frame.origin
            let originCWLB = cancelWillLogBackground.frame.origin
            
            cancelWillLog.frame = CGRect(origin: willLog.frame.origin, size: cancelWillLog.frame.size)
            cancelWillLogBackground.frame = CGRect(origin: willLogBackground.frame.origin, size: cancelWillLogBackground.frame.size)
            
            toggleCancelWillLogVisibility(isHidden: false)
            
            UIView.animate(withDuration: AnimationConstant.HomeLogStateAnimate.rawValue) {
                self.cancelWillLog.frame = CGRect(origin: originCWL, size: self.cancelWillLog.frame.size)
                self.cancelWillLogBackground.frame = CGRect(origin: originCWLB, size: self.cancelWillLogBackground.frame.size)
                self.willLog.tintColor = UIColor.systemGreen
            } completion: { (completed) in
                self.toggleWillLogTouch(isTouchEnabled: true)
                self.toggleCancelWillLogTouch(isTouchEnabled: true)
            }
            
            logState = true
            /*
            if !(sender.localized is HomeMainScreenTableViewController) {
                homeMainScreenTableViewController.logState = self.logState
                homeMainScreenTableViewController.reloadTable()
            }
             */
        }
        else if newSelectionControlState! == false {
            //Visual element in current VC management
            if animated == true {
                
                //homeMainScreenTableViewController.willFadeAwayLogView()
                
                let originCWL = cancelWillLog.frame.origin
                let originCWLB = cancelWillLogBackground.frame.origin
                
                UIView.animate(withDuration: AnimationConstant.HomeLogStateAnimate.rawValue) {
                    self.cancelWillLog.frame = CGRect(origin: self.willLog.frame.origin, size: self.cancelWillLog.frame.size)
                    self.cancelWillLogBackground.frame = CGRect(origin: self.willLogBackground.frame.origin, size: self.cancelWillLogBackground.frame.size)
                    self.willLog.tintColor = UIColor.link
                    
                } completion: { (completed) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + AnimationConstant.HomeLogStateDisappearDelay.rawValue) {
                        self.toggleCancelWillLogVisibility(isHidden: true)
                        //reset button to original position but it is now hidden.
                        self.cancelWillLog.frame = CGRect(origin: originCWL, size: self.cancelWillLog.frame.size)
                        self.cancelWillLogBackground.frame = CGRect(origin: originCWLB, size: self.cancelWillLogBackground.frame.size)
                        self.toggleWillLogTouch(isTouchEnabled: true)
                    }
                }
                
                
            }
            else if animated == false {
                self.toggleCancelWillLogVisibility(isHidden: true)
                self.willLog.tintColor = UIColor.link
                self.toggleWillLogTouch(isTouchEnabled: true)
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
        if TimingManager.enabledTimersCount == nil || TimingManager.enabledTimersCount == 0 {
            willToggleLogState(sender: Sender(origin: sender, localized: self), newSelectionControlState: nil, animated: animated)
        }
        else {
            toggleWillLogVisibility(isHidden: false)
            toggleWillLogTouch(isTouchEnabled: true)
        }
    }
    
    private func toggleWillLogVisibility(isHidden: Bool){
            self.willLog.isHidden = isHidden
            self.willLogBackground.isHidden = isHidden
    }
    
    private func toggleWillLogTouch(isTouchEnabled: Bool){
        willLog.isUserInteractionEnabled = isTouchEnabled
    }
    
    private func toggleCancelWillLogVisibility(isHidden: Bool){
            self.cancelWillLog.isHidden = isHidden
            self.cancelWillLogBackground.isHidden = isHidden
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
