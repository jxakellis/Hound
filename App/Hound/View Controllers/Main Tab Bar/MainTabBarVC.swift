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
            self.performSegueOnceInWindowHierarchy(segueIdentifier: "RemindersIntroductionViewController")
        }
    }

    // MARK: - RemindersIntroductionViewControllerDelegate

    func didComplete(sender: Sender, forDogManager dogManager: DogManager) {
        setDogManager(sender: sender, forDogManager: dogManager)
    }

    // MARK: - TimingManagerDelegate && DogsViewControllerDelegate && SettingsNavigationViewControllerDelegate

    func didUpdateDogManager(sender: Sender, forDogManager: DogManager) {
        setDogManager(sender: sender, forDogManager: forDogManager)
    }
    
    // MARK: - AlarmManagerDelegate
    
    func didAddLog(sender: Sender, forDogId dogId: Int, forLog log: Log) {
        
        let dog = try? dogManager.findDog(forDogId: dogId)
        dog?.dogLogs.addLog(forLog: log)
        setDogManager(sender: sender, forDogManager: dogManager)
    }
    
    func didRemoveLog(sender: Sender, forDogId dogId: Int, forLogId logId: Int) {
        
        let dog = try? dogManager.findDog(forDogId: dogId)
        try? dog?.dogLogs.removeLog(forLogId: logId)
        setDogManager(sender: sender, forDogManager: dogManager)
    }
    
    func didUpdateReminder(sender: Sender, forDogId dogId: Int, forReminder reminder: Reminder) {
        
        let dog = try? dogManager.findDog(forDogId: dogId)
        dog?.dogReminders.updateReminder(forReminder: reminder)
        setDogManager(sender: sender, forDogManager: dogManager)
    }
    
    func didRemoveReminder(sender: Sender, forDogId dogId: Int, forReminderId reminderId: Int) {
        
        let dog = try? dogManager.findDog(forDogId: dogId)
        try? dog?.dogReminders.removeReminder(forReminderId: reminderId)
        setDogManager(sender: sender, forDogManager: dogManager)
    }

    // MARK: - DogManagerControlFlowProtocol + ParentDogManager

    private var dogManager: DogManager = DogManager()

    static var staticDogManager: DogManager = DogManager()

    // Sets dog manager, when the value of dog manager is changed it not only changes the variable but calls other needed functions to reflect the change
    func setDogManager(sender: Sender, forDogManager: DogManager) {
        
        // MainTabBarViewController may not have been fully initalized by the time setDogManager is called on it, leading to TimingManager throwing an error possibly
        if (sender.localized is ServerSyncViewController) == false {
            TimingManager.willReinitalize(forOldDogManager: dogManager, forNewDogManager: forDogManager)
        }

        dogManager = forDogManager
        MainTabBarViewController.staticDogManager = forDogManager
        
        if (sender.localized is DogsViewController) == false {
            dogsViewController?.setDogManager(sender: Sender(origin: sender, localized: self), forDogManager: dogManager)
        }
        if (sender.localized is LogsViewController) == false {
            logsViewController?.setDogManager(sender: Sender(origin: sender, localized: self), forDogManager: dogManager)
        }
        if (sender.localized is SettingsViewController) == false {
            settingsViewController?.setDogManager(sender: Sender(origin: sender, localized: self), forDogManager: dogManager)
        }

    }

    // MARK: - Properties

    var logsNavigationViewController: LogsNavigationViewController?
    var logsViewController: LogsViewController?

    var dogsNavigationViewController: DogsNavigationViewController?
    var dogsViewController: DogsViewController?

    var settingsNavigationViewController: SettingsNavigationViewController?
    var settingsViewController: SettingsViewController?
    
    private var storedShouldRefreshDogManager: Bool = false
    
    /// This boolean is toggled to true when Hound recieves a 'reminder' or 'log' notification, meaning something with reminders or logs was updated and we should refresh
    var shouldRefreshDogManager: Bool {
        get {
            return storedShouldRefreshDogManager
        }
        set (newShouldRefreshDogManager) {
            
            print("newShouldRefreshDogManager")
            guard newShouldRefreshDogManager == true else {
                print("false")
                storedShouldRefreshDogManager = false
                return
            }
            
            guard self.isViewLoaded == true && self.view.window != nil else {
                // MainTabBarViewController isn't currently in the view hierarchy, therefore indicate that once it enters the view hierarchy it needs to refresh
                print("not hierarchy")
                storedShouldRefreshDogManager = true
                return
            }
            
            print("refreshing")
            // MainTabBarViewController is in the hierarchy so have it refresh
            _ = DogsRequest.get(invokeErrorManager: false, dogManager: dogManager) { newDogManager, _ in
                // No matter the outcome, set storedShouldRefreshDogManager to false so we don't keep invoking refreshDogManager
                self.storedShouldRefreshDogManager = false
                guard let newDogManager = newDogManager else {
                    return
                }
                self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: newDogManager)
            }
        }
    }

    static var mainTabBarViewController: MainTabBarViewController?

    /// The tab on the tab bar that the app should open to, if its the first time openning the app then go the the second tab (setup dogs) which is index 1 as index starts at 0
    static var selectedEntryIndex: Int = 0

    // MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()

        AppDelegate.generalLogger.notice("Application build is \(UIApplication.appBuild)")

        self.selectedIndex = MainTabBarViewController.selectedEntryIndex

        logsNavigationViewController = self.viewControllers![0] as? LogsNavigationViewController
        logsNavigationViewController?.passThroughDelegate = self
        logsViewController = logsNavigationViewController?.viewControllers[0] as? LogsViewController
        logsViewController?.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)

        dogsNavigationViewController = self.viewControllers![1] as? DogsNavigationViewController
        dogsNavigationViewController?.passThroughDelegate = self
        dogsViewController = dogsNavigationViewController?.viewControllers[0] as? DogsViewController
        dogsViewController?.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)

        settingsNavigationViewController = self.viewControllers![2] as? SettingsNavigationViewController
        settingsNavigationViewController?.passThroughDelegate = self
        settingsViewController = settingsNavigationViewController?.viewControllers[0] as? SettingsViewController
        settingsViewController?.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: dogManager)

        MainTabBarViewController.mainTabBarViewController = self

        TimingManager.delegate = self
        AlarmManager.delegate = self
    }

    override func viewWillAppear(_ animated: Bool) {
        // Called before the view is added to the windows’ view hierarchy
        super.viewWillAppear(animated)

        UIApplication.keyWindow?.overrideUserInterfaceStyle = UserConfiguration.interfaceStyle
        
        print("MTBVC viewWillAppear")
        if shouldRefreshDogManager == true {
            print("refreshing")
            _ = DogsRequest.get(invokeErrorManager: false, dogManager: dogManager) { newDogManager, _ in
                // No matter the outcome, set storedShouldRefreshDogManager to false so we don't keep invoking refreshDogManager
                self.storedShouldRefreshDogManager = false
                guard let newDogManager = newDogManager else {
                    return
                }
                self.setDogManager(sender: Sender(origin: self, localized: self), forDogManager: newDogManager)
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        // Called after the view is added to the view hierarchy
        super.viewDidAppear(animated)
        AlertManager.globalPresenter = self

        if FamilyConfiguration.isFamilyHead {
            InAppPurchaseManager.initalizeInAppPurchaseManager()
            InAppPurchaseManager.showPriceConsentIfNeeded()
        }
        CheckManager.checkForReleaseNotes()
        // Invocation of synchronizeNotificationAuthorization from willEnterForeground will only be accurate in conjuction with invocation of synchronizeNotificationAuthorization in viewDidAppear of MainTabBarViewController. This makes it so every time Hound is opened, either from the background or from terminated, notifications are properly synced.
        // 1. Hound entering foreground from being terminated. willEnterForeground isn't called upon inital launch of Hound, only once Hound is sent to background then brought back to foreground, but viewDidAppear MainTabBarViewController will catch as it's invoked once ServerSyncViewController is done loading
        // 2. Hound entering foreground after entering background. viewDidAppear MainTabBarViewController won't catch as MainTabBarViewController's view isn't appearing anymore but willEnterForeground will catch any imbalance as it's called once app is loaded to foreground
        NotificationManager.synchronizeNotificationAuthorization()
        TimingManager.willInitalize(forDogManager: dogManager)
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
        if let remindersIntroductionViewController: RemindersIntroductionViewController = segue.destination as? RemindersIntroductionViewController {
            remindersIntroductionViewController.delegate = self
            remindersIntroductionViewController.dogManager = dogManager
        }
     }

}
