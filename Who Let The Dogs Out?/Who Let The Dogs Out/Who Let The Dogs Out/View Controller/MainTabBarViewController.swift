//
//  MainTabBarViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/1/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController, DogManagerControlFlowProtocol, DogsViewControllerDelegate, TimingManagerDelegate, SettingsViewControllerDelegate {
    
    //MARK: SettingsViewControllerDelegate
    
    func didTogglePause(newPauseState: Bool) {
        TimingManager.willTogglePause(dogManager: getDogManager(), newPauseStatus: newPauseState)
    }
    
    //MARK: TimingManagerDelegate && DogsViewControllerDelegate
    
    func didUpdateDogManager(newDogManager: DogManager, sender: AnyObject?) {
        setDogManager(newDogManager: newDogManager, sender: sender)
    }
    
    //MARK: Master Dog Manager
    
    private var masterDogManager: DogManager = DogManager()
    
    static var staticDogManager: DogManager = DogManager()
    
    //Get method, returns a copy of dogManager to remove possible editting of dog manager through class reference type
    func getDogManager() -> DogManager {
        return masterDogManager.copy() as! DogManager
    }
    
    //Sets dog manager, when the value of dog manager is changed it not only changes the variable but calls other needed functions to reflect the change
    func setDogManager(newDogManager: DogManager, sender: AnyObject?){
        
        //possible senders
        //MainTabBarViewController
        //TimingManager
        //DogsViewController
        
        masterDogManager = newDogManager.copy() as! DogManager
        MainTabBarViewController.staticDogManager = newDogManager.copy() as! DogManager
        
        if sender is TimingManager.Type || sender is TimingManager{
            dogsViewController.setDogManager(newDogManager: getDogManager(), sender: self)
            homeViewController.setDogManager(newDogManager: getDogManager(), sender: self)
        }
        
        if sender is DogsViewController {
            homeViewController.setDogManager(newDogManager: getDogManager(), sender: self)
        }
        
        if !(sender is MainTabBarViewController){
            self.updateDogManagerDependents()
        }
        
    }
    
    func updateDogManagerDependents() {
        TimingManager.willReinitalize(dogManager: getDogManager())
    }
    
    //MARK: Main
    
    var dogsViewController: DogsViewController! = nil
    
    var settingsViewController: SettingsViewController! = nil
    
    var homeViewController: HomeViewController! = nil
    
    static var mainTabBarViewController: MainTabBarViewController! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let decoded = UserDefaults.standard.object(forKey: "dogManager") as! Data
        let decodedDogManager = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded) as! DogManager
        
        setDogManager(newDogManager: decodedDogManager, sender: self)
       
        dogsViewController = self.viewControllers![1] as? DogsViewController
        dogsViewController.delegate = self
        dogsViewController.setDogManager(newDogManager: getDogManager(), sender: self)
        
        settingsViewController = self.viewControllers![2] as? SettingsViewController
        settingsViewController.delegate = self
        
        homeViewController = self.viewControllers![0] as? HomeViewController
        homeViewController.setDogManager(newDogManager: getDogManager(), sender: self)
        //homeViewController.delegate = self
        
        MainTabBarViewController.mainTabBarViewController = self
        
        TimingManager.delegate = self
        TimingManager.willInitalize(dogManager: getDogManager())
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Utils.presenter = self
        super.viewWillAppear(animated)
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
