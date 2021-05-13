//
//  MainTabBarViewController.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 2/1/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//
import UIKit

class MainTabBarViewController: UITabBarController, DogManagerControlFlowProtocol, DogsNavigationViewControllerDelegate, TimingManagerDelegate, SettingsNavigationViewControllerDelegate, LogsNavigationViewControllerDelegate, IntroductionViewControllerDelegate, DogsIntroductionViewControllerDelegate {
    
    
   
    
    //MARK: - IntroductionViewControllerDelegate
    
    func didSetDogName(sender: Sender, dogName: String) {
        let sudoDogManager = getDogManager()
        try! sudoDogManager.dogs[0].dogTraits.changeDogName(newDogName: dogName)
        setDogManager(sender: sender, newDogManager: sudoDogManager)
    }
    
    func didSetDogIcon(sender: Sender, dogIcon: UIImage) {
        let sudoDogManager = getDogManager()
        sudoDogManager.dogs[0].dogTraits.icon = dogIcon
        setDogManager(sender: sender, newDogManager: sudoDogManager)
    }
     
     //MARK: - DogsNavigationViewControllerDelegate
    
    func willShowIntroductionPage() {
        self.performSegue(withIdentifier: "dogsIntroductionViewController", sender: self)
    }
    
    //MARK: - DogsIntroductionViewControllerDelegate
    
    func didSetDefaultReminderState(sender: Sender, newDefaultReminderStatus: Bool) {
        if newDefaultReminderStatus == true {
            let sudoDogManager = dogsViewController.getDogManager()
            try! sudoDogManager.dogs[0].dogRequirments.addRequirement(newRequirements: [RequirementConstant.defaultRequirementOne, RequirementConstant.defaultRequirementTwo, RequirementConstant.defaultRequirementThree])
            
            setDogManager(sender: sender, newDogManager: sudoDogManager)
        }
    }
    
    
    //MARK: - SettingsViewControllerDelegate
    
    func didTogglePause(newPauseState: Bool) {
        TimingManager.willTogglePause(dogManager: getDogManager(), newPauseStatus: newPauseState)
    }
    
    //MARK: - TimingManagerDelegate && DogsViewControllerDelegate
    
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager) {
        setDogManager(sender: sender, newDogManager: newDogManager)
    }
    
    //MARK: - DogManagerControlFlowProtocol + MasterDogManager
    
    private var masterDogManager: DogManager = DogManager()
    
    static var staticDogManager: DogManager = DogManager()
    
    //Get method, returns a copy of dogManager to remove possible editting of dog manager through class reference type
    func getDogManager() -> DogManager {
        //DogManagerEfficencyImprovement return masterDogManager.copy() as! DogManager
        return masterDogManager
    }
    
    //Sets dog manager, when the value of dog manager is changed it not only changes the variable but calls other needed functions to reflect the change
    func setDogManager(sender: Sender, newDogManager: DogManager){
        
        //possible senders
        //MainTabBarViewController
        //TimingManager
        //DogsViewController
        
        //DogManagerEfficencyImprovement masterDogManager = newDogManager.copy() as! DogManager
        //DogManagerEfficencyImprovement MainTabBarViewController.staticDogManager = newDogManager.copy() as! DogManager
        
        masterDogManager = newDogManager
        MainTabBarViewController.staticDogManager = newDogManager
        
        
        
        
        //Updates isPaused to reflect any changes in data, if there are no enabled/creaed requirements or no enabled/created dogs then turns isPaused off as there is nothing to pause
        if getDogManager().hasCreatedRequirement == false || getDogManager().hasEnabledRequirement == false || getDogManager().hasEnabledDog == false {
            TimingManager.isPaused = false
        }
        
        if sender.localized is TimingManager.Type || sender.localized is TimingManager{
            //homeViewController?.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
            logsViewController.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
            dogsViewController.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
        }
        
        else if sender.localized is DogsViewController {
            //homeViewController?.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
            logsViewController.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
        }
        
        else if sender.localized is LogsViewController {
            //homeViewController?.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
            dogsViewController.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
        }
        
        else if sender.localized is IntroductionViewController || sender.localized is DogsIntroductionViewController{
            //homeViewController?.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
            logsViewController.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
            dogsViewController.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
        }
        
        if !(sender.localized is MainTabBarViewController){
            self.updateDogManagerDependents()
        }
        
    }
    
    func updateDogManagerDependents() {
        TimingManager.willReinitalize(dogManager: getDogManager())
    }
    
    //MARK: - Properties
    
    var homeNavigationViewController: HomeNavigationViewController? = nil
    var homeViewController: HomeViewController? = nil
    
    var logsNavigationViewController: LogsNavigationViewController! = nil
    var logsViewController: LogsViewController! = nil
    
    var dogsNavigationViewController: DogsNavigationViewController! = nil
    var dogsViewController: DogsViewController! = nil
    
    var settingsNavigationViewController: SettingsNavigationViewController! = nil
    var settingsViewController: SettingsViewController! = nil
    
    static var firstTimeSetup: Bool = false
    
    static var mainTabBarViewController: MainTabBarViewController! = nil
    
    ///The tab on the tab bar that the app should open to, if its the first time openning the app then go the the second tab (setup dogs) which is index 1 as index starts at 0
    static var selectedEntryIndex: Int = 0
    
    //MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let decoded = UserDefaults.standard.object(forKey: UserDefaultsKeys.dogManager.rawValue) as! Data
        var decodedDogManager = try! NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(decoded) as! DogManager
        decodedDogManager.synchronizeIsSkipping()
        
        setDogManager(sender: Sender(origin: self, localized: self), newDogManager: decodedDogManager)
        
        self.selectedIndex = MainTabBarViewController.selectedEntryIndex
        
        /*
         homeNavigationViewController = self.viewControllers![0] as? HomeNavigationViewController
         homeViewController = homeNavigationViewController.viewControllers[0] as? HomeViewController
         homeViewController.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: getDogManager())
         */
        
        logsNavigationViewController = self.viewControllers![0] as? LogsNavigationViewController
        logsNavigationViewController.passThroughDelegate = self
        logsViewController = logsNavigationViewController.viewControllers[0] as? LogsViewController
        logsViewController.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: getDogManager())
       
        dogsNavigationViewController = self.viewControllers![1] as? DogsNavigationViewController
        dogsNavigationViewController.passThroughDelegate = self
        dogsViewController = dogsNavigationViewController.viewControllers[0] as? DogsViewController
        dogsViewController.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: getDogManager())
        
        settingsNavigationViewController = self.viewControllers![2] as? SettingsNavigationViewController
        settingsNavigationViewController.passThroughDelegate = self
        settingsViewController = settingsNavigationViewController.viewControllers[0] as? SettingsViewController
        
        MainTabBarViewController.mainTabBarViewController = self
        
        TimingManager.delegate = self
        TimingManager.willInitalize(dogManager: getDogManager())
        
        UserDefaults.standard.setValue(false, forKey: "didCrashDuringSetup")
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
        
        if MainTabBarViewController.firstTimeSetup == true {
            MainTabBarViewController.firstTimeSetup = false
            self.performSegue(withIdentifier: "introductionViewController", sender: self)
        }
    }
    
    override open var shouldAutorotate: Bool {
        return false
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask{
        return .portrait
    }
    
    
    
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "introductionViewController"{
            let introductionViewController: IntroductionViewController = segue.destination as! IntroductionViewController
            introductionViewController.delegate = self
        }
        if segue.identifier == "dogsIntroductionViewController"{
            let dogsIntroductionViewController: DogsIntroductionViewController = segue.destination as! DogsIntroductionViewController
            dogsIntroductionViewController.delegate = self
        }
     }
     
    
}
