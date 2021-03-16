//
//  Utils.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/10/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class Utils
{
    ///Default sender used to present, this is necessary if an alert to be shown is called from a non UIViewController class as that is not in the view heirarchy and physically cannot present a view, so this is used instead.
    static var presenter: UIViewController = UIViewController.init()
    
    ///Function used to present alertController, Utils.presenter is a default sender if non is specified, title and message are specifiable but other information is set to defaults.
    static func willShowAlert(title: String, message: String)
    {
        
        let alertController = CustomAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        
        let alertAction = UIAlertAction(
            title:"OK",
            style: .default,
            handler:
                {
                    (alert: UIAlertAction!)  in
                })
        
        alertController.addAction(alertAction)
        
        AlertPresenter.shared.enqueueAlertForPresentation(alertController)
        
    }
    
    static func willCreateUNUserNotification(dogName: String, requirementName: String, executionDate: Date){
        
         let content = UNMutableNotificationContent()
         content.title = "Reminder for \(dogName)"
         content.body = "\(requirementName)"
        
        let executionDateComponents = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second], from: executionDate)
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: executionDateComponents, repeats: false)
        
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { (error) in
            if (error != nil){
                print("willCreateUNUserNotification error: \(error!.localizedDescription)")
            }
        }
    }
}

class Persistence{
    ///Called by App or Scene Delegate when setting up in didFinishLaunchingWithOptions, can be either the first time setup or a recurring setup (i.e. not the app isnt being opened for the first time)
    static func willSetup(isRecurringSetup: Bool = false){
        
        if isRecurringSetup == true{
            //not first time setup
            
            TimingManager.isPaused = UserDefaults.standard.value(forKey: UserDefaultsKeys.isPaused.rawValue) as! Bool
            TimingManager.lastPause = UserDefaults.standard.value(forKey: UserDefaultsKeys.lastPause.rawValue) as? Date
            TimingManager.lastUnpause = UserDefaults.standard.value(forKey: UserDefaultsKeys.lastUnpause.rawValue) as? Date
            
           TimerConstant.defaultSnooze = UserDefaults.standard.value(forKey: UserDefaultsKeys.defaultSnooze.rawValue) as! TimeInterval
            
        }
        
        else {
            //first time setup
            let data = DogManagerConstant.defaultDogManager
            let encodedData = try! NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
            UserDefaults.standard.setValue(encodedData, forKey: UserDefaultsKeys.dogManager.rawValue)
            
            UserDefaults.standard.setValue(TimingManager.isPaused, forKey: UserDefaultsKeys.isPaused.rawValue)
            UserDefaults.standard.setValue(TimingManager.lastPause, forKey: UserDefaultsKeys.lastPause.rawValue)
            UserDefaults.standard.setValue(TimingManager.lastUnpause, forKey: UserDefaultsKeys.lastUnpause.rawValue)
            
            UserDefaults.standard.setValue(TimerConstant.defaultSnooze, forKey: UserDefaultsKeys.defaultSnooze.rawValue)
            
            UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (isGranted, error) in
                UserDefaults.standard.setValue(isGranted, forKey: UserDefaultsKeys.isRequestAuthorizationGranted.rawValue)
                UserDefaults.standard.setValue(isGranted, forKey: UserDefaultsKeys.isNotificationEnabled.rawValue)
            }
        }
    }
    
    ///Called by App or Scene Delegate when entering the background, used to save information, can be called when terminating for a slightly modifed case.
    static func willEnterBackground(isTerminating: Bool = false){
        
        //dogManager
        let dataDogManager = MainTabBarViewController.staticDogManager.copy() as! DogManager
        let encodedDataDogManager = try! NSKeyedArchiver.archivedData(withRootObject: dataDogManager, requiringSecureCoding: false)
         UserDefaults.standard.setValue(encodedDataDogManager, forKey: UserDefaultsKeys.dogManager.rawValue)
        
        //Pause State
        UserDefaults.standard.setValue(TimingManager.isPaused, forKey: UserDefaultsKeys.defaultSnooze.rawValue)
        UserDefaults.standard.setValue(TimingManager.lastPause, forKey: UserDefaultsKeys.lastPause.rawValue)
        UserDefaults.standard.setValue(TimingManager.lastUnpause, forKey: UserDefaultsKeys.lastUnpause.rawValue)
        
        //Snooze interval
        
        UserDefaults.standard.setValue(TimerConstant.defaultSnooze, forKey: UserDefaultsKeys.defaultSnooze.rawValue)
        
        //notification on off and authorization
        //SettingsVC.ISN and .ISA are both calculated properties so no need to update.
       // UserDefaults.standard.setValue(SettingsViewController.isNotificationEnabled, forKey: UserDefaultsKeys.isNotificationEnabled.rawValue)
        //UserDefaults.standard.setValue(SettingsViewController.isNotificationAuthorized, forKey: UserDefaultsKeys.isRequestAuthorizationGranted.rawValue)
        
        if isTerminating == true  {
            
        }
        
        else {
            if UserDefaults.standard.value(forKey: UserDefaultsKeys.isRequestAuthorizationGranted.rawValue) as! Bool == true
                && UserDefaults.standard.value(forKey: UserDefaultsKeys.isNotificationEnabled.rawValue) as! Bool == true
                && UserDefaults.standard.value(forKey: UserDefaultsKeys.isPaused.rawValue) as! Bool == false{
                for dogKey in TimingManager.timerDictionary.keys{
                    for requirementKey in TimingManager.timerDictionary[dogKey]!.keys{
                        guard TimingManager.timerDictionary[dogKey]![requirementKey]! != nil && TimingManager.timerDictionary[dogKey]![requirementKey]!!.isValid else{
                            continue
                        }
                        Utils.willCreateUNUserNotification(dogName: dogKey, requirementName: requirementKey, executionDate: TimingManager.timerDictionary[dogKey]![requirementKey]!!.fireDate)
                    }
                }
            }
        }
        
    }
    
    static func willEnterForeground(){
        checkIsNotificationAuthorizationGranted()
        
        if UserDefaults.standard.value(forKey: UserDefaultsKeys.isRequestAuthorizationGranted.rawValue) != nil && UserDefaults.standard.value(forKey: UserDefaultsKeys.isRequestAuthorizationGranted.rawValue) as! Bool == true{
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        }
    }
    
    ///Checks to see if a change in notification permissions has occured, if it has then update to reflect
    static private func checkIsNotificationAuthorizationGranted() {
        UNUserNotificationCenter.current().getNotificationSettings { (permission) in
            switch permission.authorizationStatus {
            case .authorized:
                UserDefaults.standard.setValue(true, forKey: UserDefaultsKeys.isRequestAuthorizationGranted.rawValue)
            case .denied:
                print(".denied")
                UserDefaults.standard.setValue(false, forKey: UserDefaultsKeys.isRequestAuthorizationGranted.rawValue)
                UserDefaults.standard.setValue(false, forKey: UserDefaultsKeys.isNotificationEnabled.rawValue)
                //Updates switch to reflect change, if the last view open was the settings page then the app is exitted and property changed in the settings app then this app is reopened, VWL will not be called as the settings page was already opened, weird edge case.
                DispatchQueue.main.async {
                    let settingsVC: SettingsViewController? = MainTabBarViewController.mainTabBarViewController.settingsViewController
                    if settingsVC != nil && settingsVC!.isViewLoaded && settingsVC!.isNotificationEnabledSwitch != nil {
                        let notifSwitch: UISwitch! = settingsVC!.isNotificationEnabledSwitch
                        if notifSwitch.isOn != UserDefaults.standard.value(forKey: UserDefaultsKeys.isNotificationEnabled.rawValue) as! Bool {
                            notifSwitch.setOn(UserDefaults.standard.value(forKey: UserDefaultsKeys.isNotificationEnabled.rawValue) as! Bool, animated: true)
                        }
                    }
                }
            case .notDetermined:
                print(".notDetermined")
            case .provisional:
                print(".provisional")
            case .ephemeral:
                print(".ephemeral")
            @unknown default:
                print("unknown")
            }
        }
        
       
    }
}

class ErrorProcessor{
    
    ///Alerts for an error, just calls Utils.willShowAlert currently with a specified title of "Error"
    static func alertForError(message: String){
        
        Utils.willShowAlert(title: "Error", message: message)
        
    }
    
    private static func alertForErrorProcessor(sender: Sender, message: String){
        let originTest = sender.origin
        if originTest != nil{
            Utils.willShowAlert(title: "Error from \(NSStringFromClass(originTest!.classForCoder))", message: message)
        }
        else {
            Utils.willShowAlert(title: "Error from unknown class", message: message)
        }
        
    }
    
    ///Handles a given error, uses helper functions to compare against all known (custom) error types
    static func handleError(sender: Sender, error: Error){
        
        let errorProcessorInstance = ErrorProcessor()
        
        if errorProcessorInstance.handleDogSpecificationManagerError(sender: sender, error: error) == true {
            return
        }
        else if errorProcessorInstance.handleDogRequirementError(sender: sender, error: error) == true {
            return
        }
        else if errorProcessorInstance.handleDogRequirementManagerError(sender: sender, error: error) == true {
            return
        }
        else if errorProcessorInstance.handleDogManagerError(sender: sender, error: error) == true{
            return
        }
        else if errorProcessorInstance.handleMiscError(sender: sender, error: error) == true{
            return
        }
        else {
            ErrorProcessor.alertForErrorProcessor(sender: sender, message: "Unable to desifer error of description: \(error.localizedDescription)")
        }
    }
    
    ///Returns true if able to find a match in enum DogSpecificationManagerError to the error provided
    private func handleDogSpecificationManagerError(sender: Sender, error: Error) -> Bool{
        /*
         case nilKey
         case blankKey
         case invalidKey
         case keyNotPresentInGlobalConstantList
         // the strings are the key that the value used
         case nilNewValue(String)
         case blankNewValue(String)
         case invalidNewValue(String)
         */
        if case DogSpecificationManagerError.nilKey = error {
            ErrorProcessor.alertForErrorProcessor(sender: sender, message: "Big Time Error! Nil Key")
            return true
        }
        else if case DogSpecificationManagerError.blankKey = error {
            ErrorProcessor.alertForErrorProcessor(sender: sender, message: "Big Time Error! Blank Key")
            return true
        }
        else if case DogSpecificationManagerError.invalidKey = error{
            ErrorProcessor.alertForErrorProcessor(sender: sender, message: "Big Time Error! Invalid Key")
            return true
        }
        else if case DogSpecificationManagerError.nilNewValue("name") = error {
            ErrorProcessor.alertForError(message: "Your dog has an invalid name, try typing something else in!")
            return true
        }
        else if case DogSpecificationManagerError.blankNewValue("name") = error {
            ErrorProcessor.alertForError(message: "Your dog has a blank name, try typing something in!")
            return true
        }
        //Do not punish for an empty description, theoretically possible to happen though so added
        else if case DogSpecificationManagerError.nilNewValue("description") = error {
            ErrorProcessor.alertForError(message: "Your dog has a invalid description, try typing something else in!")
            return true
        }
        //These should not be needed but are here as they are theoretically possible
        else if case DogSpecificationManagerError.blankNewValue("description") = error {
            ErrorProcessor.alertForError(message: "Your dog has a blank description, try typing something in!")
            return true
        }
        //These should not be needed but are here as they are theoretically possible
        else if case DogSpecificationManagerError.invalidNewValue("description") = error {
            ErrorProcessor.alertForError(message: "Your dog has an invalid description, try typing something else in!")
            return true
        }
        else{
            return false
        }
    }
    
    ///Returns true if able to find a match in enum DogManagerError to the error provided
    private func handleDogManagerError(sender: Sender, error: Error) -> Bool{
        /*
         case dogNameNotPresent
         case dogNameAlreadyPresent
         case dogNameInvalid
         case dogNameBlank
         */
        if case DogManagerError.dogNameNotPresent = error {
            ErrorProcessor.alertForError(message: "Could not find a match for a dog matching your name!")
            return true
        }
        else if case DogManagerError.dogNameAlreadyPresent = error {
            ErrorProcessor.alertForError(message: "Your dog's name is already present, please try a different one.")
            return true
        }
        else if case DogManagerError.dogNameInvalid = error {
            ErrorProcessor.alertForError(message: "Your dog's name is invalid, please try a different one.")
            return true
        }
        else if case DogManagerError.dogNameBlank = error {
            ErrorProcessor.alertForError(message: "Your dog's name is blank, try typing something in.")
            return true
        }
        else{
            return false
        }
    }
    
    ///Returns true if able to find a match in enum DogRequirementError to the error provided
    private func handleDogRequirementError(sender: Sender, error: Error) -> Bool{
        /*
         case nameInvalid
         case descriptionInvalid
         case intervalInvalid
         */
        if case DogRequirementError.nameInvalid = error {
            ErrorProcessor.alertForError(message: "Your dog's reminder name is invalid, please try a different one.")
            return true
        }
        else if case DogRequirementError.descriptionInvalid = error {
            ErrorProcessor.alertForError(message: "Your dog's reminder description is invalid, please try a different one.")
            return true
        }
        else if case DogRequirementError.intervalInvalid = error {
            ErrorProcessor.alertForError(message: "Your dog's reminder countdown time is invalid, please try a different one.")
            return true
        }
        else{
            return false
        }
    }
    
    ///Returns true if able to find a match in enum DogRequirementManagerError to the error provided
    private func handleDogRequirementManagerError(sender: Sender, error: Error) -> Bool{
        /*
         case requirementAlreadyPresent
         case requirementNotPresent
         case requirementInvalid
         */
        if case DogRequirementManagerError.requirementAlreadyPresent = error {
            ErrorProcessor.alertForError(message: "Your reminder's name is already present, please try a different one.")
            return true
        }
        else if case DogRequirementManagerError.requirementNotPresent = error{
            ErrorProcessor.alertForError(message: "Could not find a match for your reminder!")
            return true
        }
        else if case DogRequirementManagerError.requirementInvalid = error {
            ErrorProcessor.alertForError(message: "Your reminder is invalid, please try something different.")
            return true
        }
        else{
            return false
        }
    }
    
    ///Returns true if able to find a match in one of a few small custom error enums
    private func handleMiscError(sender: Sender, error: Error) -> Bool {
        if case DogError.noRequirementsPresent = error {
            ErrorProcessor.alertForError(message: "Your dog has no reminders, please try adding one.")
            return true
        }
        else if case TimingManagerError.invalidateFailed = error {
            ErrorProcessor.alertForError(message: "Unable to invalidate the timer handling a certain reminder")
            return true
        }
        else if case TimingManagerError.parseSenderInfoFailed = error {
            ErrorProcessor.alertForError(message: "Unable to parse sender info in TimingManager")
            return true
        }
        else {
            return false
        }
    }
}



