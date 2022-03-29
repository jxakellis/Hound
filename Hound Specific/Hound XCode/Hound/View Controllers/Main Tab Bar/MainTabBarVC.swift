//
//  MainTabBarViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/1/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//
import UIKit

class MainTabBarViewController: UITabBarController, DogManagerControlFlowProtocol, DogsNavigationViewControllerDelegate, TimingManagerDelegate, SettingsNavigationViewControllerDelegate, LogsNavigationViewControllerDelegate, RemindersIntroductionViewControllerDelegate, AlarmManagerDelegate {

     // MARK: - DogsNavigationViewControllerDelegate

    func checkForRemindersIntroductionPage() {
        // figure out where to go next, if the user is new and has no reminders for their dog (aka probably no family yet either) then we help them make their first reminder
        
        // hasn't shown configuration to create reminders
        if LocalConfiguration.hasLoadedRemindersIntroductionViewControllerBefore == false {
            // never created a reminder before, new family
            if self.getDogManager().hasCreatedReminder == false {
                self.performSegue(withIdentifier: "remindersIntroductionViewController", sender: self)
            }
            // reminders already created
            else {
                // TO DO create intro page for additional family member, where they still get introduced but don't create a reminder
                LocalConfiguration.hasLoadedRemindersIntroductionViewControllerBefore = true
            }
            
        }
    }

    // MARK: - RemindersIntroductionViewControllerDelegate

    func didComplete(sender: Sender, forReminders reminders: [Reminder]) {
        let sudoDogManager = getDogManager()
        if sudoDogManager.hasCreatedDog == true {
            let dog = sudoDogManager.dogs[0]
            dog.dogReminders.addReminder(newReminders: reminders)
            setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: sudoDogManager)
        }
    }

    // MARK: - SettingsViewControllerDelegate

    func didToggleIsPaused(newIsPaused: Bool) {
        TimingManager.willTogglePause(dogManager: getDogManager(), newPauseStatus: newIsPaused)
    }

    // MARK: - TimingManagerDelegate && DogsViewControllerDelegate && AlarmManagerDelegate

    func didUpdateDogManager(sender: Sender, newDogManager: DogManager) {
        setDogManager(sender: sender, newDogManager: newDogManager)
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

        // possible senders
        // MainTabBarViewController
        // TimingManager
        // DogsViewController

        parentDogManager = newDogManager
        MainTabBarViewController.staticDogManager = newDogManager

        // Updates isPaused to reflect any changes in data, if there are no enabled reminders then turns isPaused off as there is nothing to pause. For hasEnabledReminder to be true, the dog manager must have >=1 dog, have >=1 reminder, and >= 1 reminder turned on.
        if getDogManager().hasEnabledReminder == false && UserConfiguration.isPaused == true {
            UserConfiguration.isPaused = false

            let body = [UserDefaultsKeys.isPaused.rawValue: UserConfiguration.isPaused]
            UserRequest.update(body: body) { requestWasSuccessful in
                if requestWasSuccessful == false {
                    // revert all values
                    UserConfiguration.isPaused = true
                }
            }
        }
        
        // If the dogManager is sent from ServerSyncViewController or IntroductionViewController, then, at that point in time, nothing here is initalized and will cause a crash
        guard !(sender.localized is ServerSyncViewController) && !(sender.origin is ServerSyncViewController) &&  !(sender.localized is IntroductionViewController) && !(sender.origin is IntroductionViewController) else {
            return
        }

        if sender.localized is TimingManager.Type || sender.localized is TimingManager || sender.localized is AlarmManager.Type || sender.localized is AlarmManager {
            logsViewController.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
            dogsViewController.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
        }
        else if sender.localized is DogsViewController {
            logsViewController.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
        }
        else if sender.localized is LogsViewController {
            dogsViewController.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
        }
        else if sender.localized is RemindersIntroductionViewController {
            logsViewController.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
            dogsViewController.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
        }

        if !(sender.localized is MainTabBarViewController) {
            self.updateDogManagerDependents()
        }

    }

    func updateDogManagerDependents() {
        TimingManager.willReinitalize(dogManager: getDogManager())
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

        MainTabBarViewController.mainTabBarViewController = self

        TimingManager.delegate = self
        AlarmManager.delegate = self

        UserDefaults.standard.setValue(false, forKey: "didCrashDuringSetup")
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

        let sudoDogManager = getDogManager()
        Utils.checkForTermination(forDogManager: sudoDogManager)
        Utils.checkForReleaseNotes()
        TimingManager.willInitalize(dogManager: sudoDogManager)
        AlertManager.shared.refreshAlarms(dogManager: sudoDogManager)
        
    }

    override open var shouldAutorotate: Bool {
        return false
    }

    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
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
