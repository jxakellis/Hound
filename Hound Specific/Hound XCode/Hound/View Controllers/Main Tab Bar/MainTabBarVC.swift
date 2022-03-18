//
//  MainTabBarViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/1/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//
import UIKit

class MainTabBarViewController: UITabBarController, DogManagerControlFlowProtocol, DogsNavigationViewControllerDelegate, TimingManagerDelegate, SettingsNavigationViewControllerDelegate, LogsNavigationViewControllerDelegate, IntroductionViewControllerDelegate, DogsIntroductionViewControllerDelegate {

    // MARK: - IntroductionViewControllerDelegate

    func didSetDogName(sender: Sender, dogName: String) {
        let sudoDogManager = getDogManager()
        try! sudoDogManager.dogs[0].changeDogName(newDogName: dogName)
        setDogManager(sender: sender, newDogManager: sudoDogManager)
    }

    func didSetDogIcon(sender: Sender, dogIcon: UIImage) {
        let sudoDogManager = getDogManager()
        sudoDogManager.dogs[0].icon = dogIcon
        setDogManager(sender: sender, newDogManager: sudoDogManager)
    }

     // MARK: - DogsNavigationViewControllerDelegate

    func willShowIntroductionPage() {
        self.performSegue(withIdentifier: "dogsIntroductionViewController", sender: self)
    }

    // MARK: - DogsIntroductionViewControllerDelegate

    func didSetDefaultReminderState(sender: Sender, newDefaultReminderStatus: Bool) {
        if newDefaultReminderStatus == true {
            let sudoDogManager = dogsViewController.getDogManager()
            sudoDogManager.dogs[0].dogReminders.addDefaultReminders()

            setDogManager(sender: sender, newDogManager: sudoDogManager)
        }
    }

    // MARK: - SettingsViewControllerDelegate

    func didToggleIsPaused(newIsPaused: Bool) {
        TimingManager.willTogglePause(dogManager: getDogManager(), newPauseStatus: newIsPaused)
    }

    // MARK: - TimingManagerDelegate && DogsViewControllerDelegate

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

            UserRequest.update(body: [UserDefaultsKeys.isPaused.rawValue: UserConfiguration.isPaused]) { _, responseCode, _ in
                DispatchQueue.main.async {
                    // success
                    if responseCode != nil && 200...299 ~= responseCode! {
                        // do nothing as we preemptively updated the values
                    }
                    // error, revert to previous
                    else {
                        ErrorManager.alert(sender: Sender(origin: self, localized: self), forError: UserConfigurationResponseError.updateIsPausedFailed)

                        // revert all values
                        UserConfiguration.isPaused = false
                    }
                }
            }
        }

        if sender.localized is TimingManager.Type || sender.localized is TimingManager {
            logsViewController.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
            dogsViewController.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
        }
        else if sender.localized is DogsViewController {
            logsViewController.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
        }
        else if sender.localized is LogsViewController {
            dogsViewController.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
        }
        else if sender.localized is IntroductionViewController || sender.localized is DogsIntroductionViewController {
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

        setDogManager(sender: Sender(origin: self, localized: self), newDogManager: ServerSyncViewController.dogManager)

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

        Utils.checkForTermination()
        Utils.checkForReleaseNotes()

        TimingManager.willInitalize(dogManager: getDogManager())
        AlertManager.shared.refreshAlerts(dogManager: getDogManager())

        if LocalConfiguration.hasLoadedIntroductionViewControllerBefore == false {
            // self.performSegue(withIdentifier: "introductionViewController", sender: self)
        }
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
