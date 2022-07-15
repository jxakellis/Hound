//
//  MainTabBarViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/1/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//
import UIKit

final class MainTabBarViewController: UITabBarController, DogManagerControlFlowProtocol, DogsNavigationViewControllerDelegate, TimingManagerDelegate, LogsNavigationViewControllerDelegate, RemindersIntroductionViewControllerDelegate, AlarmManagerDelegate, SettingsNavigationViewControllerDelegate {
    
     // MARK: - DogsNavigationViewControllerDelegate

    func checkForRemindersIntroductionPage() {
        // figure out where to go next, if the user is new and has no reminders for their dog (aka probably no family yet either) then we help them make their first reminder
        
        // hasn't shown configuration to create reminders
        if LocalConfiguration.hasLoadedRemindersIntroductionViewControllerBefore == false {
            // Created family with no reminders
            // Joined family with no reminders
            // Joined family with reminders
            self.performSegueOnceInWindowHierarchy(segueIdentifier: "remindersIntroductionViewController")
        }
    }

    // MARK: - RemindersIntroductionViewControllerDelegate

    func didComplete(sender: Sender, forDogManager dogManager: DogManager) {
        setDogManager(sender: sender, newDogManager: dogManager)
    }

    // MARK: - TimingManagerDelegate && DogsViewControllerDelegate && SettingsNavigationViewControllerDelegate

    func didUpdateDogManager(sender: Sender, newDogManager: DogManager) {
        setDogManager(sender: sender, newDogManager: newDogManager)
    }
    
    // MARK: - AlarmManagerDelegate
    
    func didAddLog(sender: Sender, dogId: Int, log: Log) {
        let sudoDogManager = getDogManager()
        let dog = try! sudoDogManager.findDog(forDogId: dogId)
        dog.dogLogs.addLog(forLog: log)
        setDogManager(sender: sender, newDogManager: sudoDogManager)
    }
    
    func didRemoveLog(sender: Sender, dogId: Int, logId: Int) {
        let sudoDogManager = getDogManager()
        let dog = try! sudoDogManager.findDog(forDogId: dogId)
        try! dog.dogLogs.removeLog(forLogId: logId)
        setDogManager(sender: sender, newDogManager: sudoDogManager)
    }
    
    func didUpdateReminder(sender: Sender, dogId: Int, reminder: Reminder) {
        let sudoDogManager = getDogManager()
        let dog = try! sudoDogManager.findDog(forDogId: dogId)
        dog.dogReminders.updateReminder(forReminder: reminder)
        setDogManager(sender: sender, newDogManager: sudoDogManager)
    }
    
    func didRemoveReminder(sender: Sender, dogId: Int, reminderId: Int) {
        let sudoDogManager = getDogManager()
        let dog = try! sudoDogManager.findDog(forDogId: dogId)
        try! dog.dogReminders.removeReminder(forReminderId: reminderId)
        setDogManager(sender: sender, newDogManager: sudoDogManager)
    }
    
    func shouldRefreshDogManager(sender: Sender) {
        DogsRequest.get(invokeErrorManager: true, dogManager: getDogManager()) { newDogManager, _ in
            if newDogManager != nil {
                self.setDogManager(sender: sender, newDogManager: newDogManager!)
            }
        }
    }

    // MARK: - DogManagerControlFlowProtocol + ParentDogManager

    private var parentDogManager: DogManager = DogManager()

    static var staticDogManager: DogManager = DogManager()

    // Get method, returns a copy of dogManager to remove possible editting of dog manager through class reference type
    func getDogManager() -> DogManager {
        return parentDogManager
    }

    // Sets dog manager, when the value of dog manager is changed it not only changes the variable but calls other needed functions to reflect the change
    func setDogManager(sender: Sender, newDogManager: DogManager) {
        
        // MainTabBarViewController may not have been fully initalized by the time setDogManager is called on it, leading to TimingManager throwing an error possibly
        if !(sender.localized is MainTabBarViewController) {
            TimingManager.willReinitalize(forOldDogManager: getDogManager(), forNewDogManager: newDogManager)
        }

        parentDogManager = newDogManager
        MainTabBarViewController.staticDogManager = newDogManager
        
        // If the dogManager is sent from ServerSyncViewController or IntroductionViewController, then, at that point in time, nothing here is initalized and will cause a crash
        guard !(sender.localized is ServerSyncViewController) && !(sender.origin is ServerSyncViewController) &&  !(sender.localized is FamilyIntroductionViewController) && !(sender.origin is FamilyIntroductionViewController) else {
            return
        }
        
        if (sender.localized is DogsViewController) == false {
            dogsViewController.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
        }
        if (sender.localized is LogsViewController) == false {
            logsViewController.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
        }
        if (sender.localized is SettingsViewController) == false {
            settingsViewController.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
        }

    }

    // MARK: - Properties

    var logsNavigationViewController: LogsNavigationViewController! = nil
    var logsViewController: LogsViewController! = nil

    var dogsNavigationViewController: DogsNavigationViewController! = nil
    var dogsViewController: DogsViewController! = nil

    var settingsNavigationViewController: SettingsNavigationViewController! = nil
    var settingsViewController: SettingsViewController! = nil

    static var mainTabBarViewController: MainTabBarViewController! = nil

    /// The tab on the tab bar that the app should open to, if its the first time openning the app then go the the second tab (setup dogs) which is index 1 as index starts at 0
    static var selectedEntryIndex: Int = 0

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()

        AppDelegate.generalLogger.notice("Application build is \(UIApplication.appBuild)")

        self.selectedIndex = MainTabBarViewController.selectedEntryIndex

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
        settingsViewController.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: getDogManager())

        MainTabBarViewController.mainTabBarViewController = self

        TimingManager.delegate = self
        AlarmManager.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        // Called before the view is added to the windows’ view hierarchy
        super.viewWillAppear(animated)
        AlertManager.globalPresenter = self

        UIApplication.keyWindow?.overrideUserInterfaceStyle = UserConfiguration.interfaceStyle
    }

    override func viewDidAppear(_ animated: Bool) {
        // Called after the view is added to the view hierarchy
        super.viewDidAppear(animated)
        AlertManager.globalPresenter = self

        CheckManager.checkForReleaseNotes()
        CheckManager.checkForNotificationSettingImbalance()
        TimingManager.willInitalize(forDogManager: getDogManager())
    }

    override public var shouldAutorotate: Bool {
        return false
    }

    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "remindersIntroductionViewController"{
            let remindersIntroductionViewController: RemindersIntroductionViewController = segue.destination as! RemindersIntroductionViewController
            remindersIntroductionViewController.delegate = self
            remindersIntroductionViewController.dogManager = getDogManager()
        }
     }

}
