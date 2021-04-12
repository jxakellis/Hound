//
//  MainTabBarViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/1/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//
import AVFoundation
import UIKit

class MainTabBarViewController: UITabBarController, DogManagerControlFlowProtocol, DogsViewControllerDelegate, TimingManagerDelegate, SettingsViewControllerDelegate {
    
    //MARK: SettingsViewControllerDelegate
    
    func didTogglePause(newPauseState: Bool) {
        TimingManager.willTogglePause(dogManager: getDogManager(), newPauseStatus: newPauseState)
    }
    
    //MARK: TimingManagerDelegate && DogsViewControllerDelegate
    
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager) {
        setDogManager(sender: sender, newDogManager: newDogManager)
    }
    
    //MARK: DogManagerControlFlowProtocol + MasterDogManager
    
    private var masterDogManager: DogManager = DogManager()
    
    static var staticDogManager: DogManager = DogManager()
    
    //Get method, returns a copy of dogManager to remove possible editting of dog manager through class reference type
    func getDogManager() -> DogManager {
        return masterDogManager.copy() as! DogManager
    }
    
    //Sets dog manager, when the value of dog manager is changed it not only changes the variable but calls other needed functions to reflect the change
    func setDogManager(sender: Sender, newDogManager: DogManager){
        
        //possible senders
        //MainTabBarViewController
        //TimingManager
        //DogsViewController
        
        masterDogManager = newDogManager.copy() as! DogManager
        MainTabBarViewController.staticDogManager = newDogManager.copy() as! DogManager
        
        if getDogManager().hasCreatedRequirement == false || getDogManager().hasEnabledRequirement == false || getDogManager().hasEnabledDog == false {
            TimingManager.isPaused = false
        }
        
        if sender.localized is TimingManager.Type || sender.localized is TimingManager{
            dogsViewController.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
            homeViewController.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
        }
        
        if sender.localized is DogsViewController {
            homeViewController.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
        }
        
        if !(sender.localized is MainTabBarViewController){
            self.updateDogManagerDependents()
        }
        
    }
    
    func updateDogManagerDependents() {
        TimingManager.willReinitalize(dogManager: getDogManager())
    }
    
    //MARK: Properties
    
    var dogsViewController: DogsViewController! = nil
    
    var settingsViewController: SettingsViewController! = nil
    
    var homeViewController: HomeViewController! = nil
    
    static var mainTabBarViewController: MainTabBarViewController! = nil
    
    ///The tab on the tab bar that the app should open to, if its the first time openning the app then go the the second tab (configure dogs) which is index 1 as index starts at 0
    static var selectedEntryIndex: Int = 0
    
    //MARK: Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let decoded = UserDefaults.standard.object(forKey: UserDefaultsKeys.dogManager.rawValue) as! Data
        let decodedDogManager = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded) as! DogManager
        
        setDogManager(sender: Sender(origin: self, localized: self), newDogManager: decodedDogManager.copy() as! DogManager)
        
        self.selectedIndex = MainTabBarViewController.selectedEntryIndex
       
        dogsViewController = self.viewControllers![1] as? DogsViewController
        dogsViewController.delegate = self
        dogsViewController.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: getDogManager())
        
        settingsViewController = self.viewControllers![2] as? SettingsViewController
        settingsViewController.delegate = self
        
        homeViewController = self.viewControllers![0] as? HomeViewController
        homeViewController.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: getDogManager())
        //homeViewController.delegate = self
        
        MainTabBarViewController.mainTabBarViewController = self
        
        TimingManager.delegate = self
        TimingManager.willInitalize(dogManager: getDogManager())
        
        /*
        for int in 1000...1351{
            let float: Double = Double(int)
            let delay: Double = (float - 1000.0)*2.0
                DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                    print(int)
                    let systemSoundID: SystemSoundID = SystemSoundID(int)
                    AudioServicesPlayAlertSound(systemSoundID)
                }
                
            }
        */
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //Called before the view is added to the windows’ view hierarchy
        super.viewWillAppear(animated)
        Utils.presenter = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Called after the view is added to the view hierarchy
        super.viewDidAppear(animated)
        Utils.presenter = self
        AlertPresenter.shared.refresh(dogManager: getDogManager())
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
