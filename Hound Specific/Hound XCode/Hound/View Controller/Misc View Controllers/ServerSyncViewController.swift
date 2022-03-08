//
//  ServerSyncViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/3/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

class ServerSyncViewController: UIViewController {

    // MARK: - Properties

    // MARK: - Main
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        // Called before the view is added to the windows’ view hierarchy
        super.viewWillAppear(animated)
        // Make this view the presenter if the app has to present any alert.
        AlertManager.globalPresenter = self

        // make sure the view has the correct interfaceStyle
        UIApplication.keyWindow?.overrideUserInterfaceStyle = UserConfiguration.darkModeStyle

        getDogs()
    }

    // MARK: - Properties

    /// DogManager that all of the retrieved information will be added too.
    private var dogManager = DogManager()

    private var getDogsFinished = false
    private var getRemindersFinished = false
    private var getLogsFinished = false

    // MARK: - Functions

    /// Retrieve any dogs the user may have
    private func getDogs() {
        do {
            try DogsEndpoint.get(forDogId: nil, completionHandler: { body, code, error in
                self.processGetDogsResponse(responseBody: body, responseCode: code, error: error)
            })
        }
        catch {
            AppDelegate.APIResponseLogger.error("getDogs failed")
        }
    }

    /// Process the response from the getDogs query
    private func processGetDogsResponse(responseBody: [String: Any]?, responseCode: Int?, error: Error?) {
        if responseBody != nil {
            // Array of dog JSON [{dog1:'foo'},{dog2:'bar'}]
            if let result = responseBody!["result"] as? [[String: Any]] {
                for dogBody in result {
                    do {
                        // add do to the DogManager
                        let dog = Dog(fromBody: dogBody)
                        try dogManager.addDog(newDog: dog)
                        // get other components needed for the dog
                        if let dogId = dogBody["dogId"] as? Int {
                            getReminders(forDogId: dogId, forDog: dog)
                            getLogs(forDogId: dogId, forDog: dog)
                        }
                    }
                    catch {
                        AppDelegate.APIResponseLogger.error("Unable to add dog")
                    }

                }
            }
        }

        getDogsFinished = true
        finalizeSynchronization()
    }

    /// Retrieve the reminders for a specific dog.
    private func getReminders(forDogId dogId: Int, forDog dog: Dog) {
        do {
            try RemindersEndpoint.get(forDogId: dogId, forReminderId: nil, completionHandler: { body, code, error in
                self.processGetRemindersResponse(responseBody: body, responseCode: code, error: error, forDog: dog)
            })
        }
        catch {
            AppDelegate.APIResponseLogger.error("getReminders failed")
        }
    }

    private func processGetRemindersResponse(responseBody: [String: Any]?, responseCode: Int?, error: Error?, forDog dog: Dog) {
        if responseBody != nil {
            // Array of reminder JSON [{reminder1:'foo'},{reminder2:'bar'}]
            if let result = responseBody!["result"] as? [[String: Any]] {
                for reminderBody in result {
                    let reminder = Reminder(parentDog: dog, fromBody: reminderBody)
                    dog.dogReminders.addReminder(newReminder: reminder)
                }
            }
        }

        getRemindersFinished = true
        finalizeSynchronization()
    }
    /// Retrieve the reminders for a specific dog.
    private func getLogs(forDogId dogId: Int, forDog dog: Dog) {
        do {
            try LogsEndpoint.get(forDogId: dogId, forLogId: nil, completionHandler: { body, code, error in
                self.processGetLogsResponse(responseBody: body, responseCode: code, error: error, forDog: dog)
            })
        }
        catch {
            AppDelegate.APIResponseLogger.error("getLogs failed")
        }
    }

    private func processGetLogsResponse(responseBody: [String: Any]?, responseCode: Int?, error: Error?, forDog dog: Dog) {
        if responseBody != nil {
            // Array of log JSON [{log1:'foo'},{log2:'bar'}]
            if let result = responseBody!["result"] as? [[String: Any]] {
                for logBody in result {
                    let log = Log(fromBody: logBody)
                    dog.dogLogs.addLog(newLog: log)
                }
            }
        }

        getLogsFinished = true
        finalizeSynchronization()
    }

    /// Persist the new dogManager to memory and continue into the hound app
    private func finalizeSynchronization() {
        guard getDogsFinished && getRemindersFinished && getLogsFinished else {
            return
        }
        // Encode the new dogManager into userDefaults so the dogManager accessed by MainTabBarViewController is the accurate one
        let encodedDataDogManager = try! NSKeyedArchiver.archivedData(withRootObject: dogManager, requiringSecureCoding: false)
        UserDefaults.standard.setValue(encodedDataDogManager, forKey: UserDefaultsKeys.dogManager.rawValue)

        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "mainTabBarViewController", sender: nil)
        }
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
