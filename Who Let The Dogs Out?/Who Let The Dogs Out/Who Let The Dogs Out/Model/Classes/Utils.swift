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
            style: .cancel,
            handler:
                {
                    (alert: UIAlertAction!)  in
                })
        
        alertController.addAction(alertAction)
        
        AlertPresenter.shared.enqueueAlertForPresentation(alertController)
        
    }
    
    static func willShowActionSheet(sender: Sender, parentDogName: String, requirement: Requirement){
        let alertController = CustomAlertController(title: "\(requirement.requirementName) for \(parentDogName)", message: nil, preferredStyle: .actionSheet)
        
        let alertActionCancel = UIAlertAction(
            title:"Cancel",
            style: .cancel,
            handler:
                {
                    (alert: UIAlertAction!)  in
                })
        
        let alertActionDisable = UIAlertAction(
            title:"Disable",
            style: .destructive,
            handler:
                {
                    (alert: UIAlertAction!)  in
                    TimingManager.willDisableTimer(sender: sender, dogName: parentDogName, requirementName: requirement.requirementName)
                })
        
        var logTitle: String {
            if requirement.timerMode == .timeOfDay {
                if requirement.timeOfDayComponents.isSkipping == true {
                    return "Unskip Next Reminder"
                }
                else {
                    return "Skip Next Reminder"
                }
            }
            else {
                return "Log Reminder"
            }
        }
        
        let alertActionLog = UIAlertAction(
        title: logTitle,
        style: .default,
        handler:
            {
                (alert: UIAlertAction!)  in
                if requirement.timerMode == .timeOfDay {
                    TimingManager.willToggleSkipTimer(sender: sender, dogName: parentDogName, requirementName: requirement.requirementName)
                }
                else {
                    TimingManager.willResetTimer(sender: sender, dogName: parentDogName, requirementName: requirement.requirementName)
                }
                
            })
        
        alertController.addAction(alertActionCancel)
        alertController.addAction(alertActionLog)
        alertController.addAction(alertActionDisable)
        
        AlertPresenter.shared.enqueueAlertForPresentation(alertController)
        
        
    }
    
    static func willCreateFollowUpUNUserNotification(dogName: String, requirementName: String, executionDate: Date){
        let requirement = try! MainTabBarViewController.staticDogManager.findDog(dogName: dogName).dogRequirments.findRequirement(requirementName: requirementName)
         let content = UNMutableNotificationContent()
         content.title = "Follow up reminder for \(dogName)"
        
        if requirement.requirementDescription.trimmingCharacters(in: .whitespaces) != ""{
            content.body = "Five minutes ago: \(requirementName)"
        }
        else {
            content.body = "It's been five minutes, give your dog a helping hand!"
        }
        
         content.sound = .default
        
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
    
    static func willCreateUNUserNotification(dogName: String, requirementName: String, executionDate: Date){
        
        let requirement = try! MainTabBarViewController.staticDogManager.findDog(dogName: dogName).dogRequirments.findRequirement(requirementName: requirementName)
         let content = UNMutableNotificationContent()
         content.title = "Reminder for \(dogName)"
        
        if requirement.requirementDescription.trimmingCharacters(in: .whitespaces) != ""{
            content.body = "\(requirementName): \(requirement.requirementDescription)"
        }
        else {
            content.body = requirementName
        }
        
         content.sound = .default
        
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
            
            NotificationConstant.shouldFollowUp = UserDefaults.standard.value(forKey: UserDefaultsKeys.shouldFollowUp.rawValue) as! Bool
            NotificationConstant.isNotificationAuthorized = UserDefaults.standard.value(forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue) as! Bool
            NotificationConstant.isNotificationEnabled = UserDefaults.standard.value(forKey: UserDefaultsKeys.isNotificationEnabled.rawValue) as! Bool
            
        }
        
        else {
            //first time setup
            let data = DogManagerConstant.defaultDogManager
            let encodedData = try! NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: false)
            UserDefaults.standard.setValue(encodedData, forKey: UserDefaultsKeys.dogManager.rawValue)
            
            MainTabBarViewController.selectedEntryIndex = 1
            
            UserDefaults.standard.setValue(TimingManager.isPaused, forKey: UserDefaultsKeys.isPaused.rawValue)
            UserDefaults.standard.setValue(TimingManager.lastPause, forKey: UserDefaultsKeys.lastPause.rawValue)
            UserDefaults.standard.setValue(TimingManager.lastUnpause, forKey: UserDefaultsKeys.lastUnpause.rawValue)
            
            UserDefaults.standard.setValue(TimerConstant.defaultSnooze, forKey: UserDefaultsKeys.defaultSnooze.rawValue)
            
            UserDefaults.standard.setValue(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
            
            UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { (isGranted, error) in
                UserDefaults.standard.setValue(isGranted, forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue)
                UserDefaults.standard.setValue(isGranted, forKey: UserDefaultsKeys.isNotificationEnabled.rawValue)
                UserDefaults.standard.setValue(isGranted, forKey: UserDefaultsKeys.shouldFollowUp.rawValue)
                NotificationConstant.isNotificationAuthorized = isGranted
                NotificationConstant.isNotificationEnabled = isGranted
                NotificationConstant.shouldFollowUp = isGranted
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
        UserDefaults.standard.setValue(TimingManager.isPaused, forKey: UserDefaultsKeys.isPaused.rawValue)
        UserDefaults.standard.setValue(TimingManager.lastPause, forKey: UserDefaultsKeys.lastPause.rawValue)
        UserDefaults.standard.setValue(TimingManager.lastUnpause, forKey: UserDefaultsKeys.lastUnpause.rawValue)
        
        //Snooze interval
        
        UserDefaults.standard.setValue(TimerConstant.defaultSnooze, forKey: UserDefaultsKeys.defaultSnooze.rawValue)
        
        //Notifications
        
        UserDefaults.standard.setValue(NotificationConstant.shouldFollowUp, forKey: UserDefaultsKeys.shouldFollowUp.rawValue)
        UserDefaults.standard.setValue(NotificationConstant.isNotificationAuthorized, forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue)
        UserDefaults.standard.setValue(NotificationConstant.isNotificationEnabled, forKey: UserDefaultsKeys.isNotificationEnabled.rawValue)
        
        //notification on off and authorization
        //SettingsVC.ISN and .ISA are both calculated properties so no need to update.
       // UserDefaults.standard.setValue(SettingsViewController.isNotificationEnabled, forKey: UserDefaultsKeys.isNotificationEnabled.rawValue)
        //UserDefaults.standard.setValue(SettingsViewController.isNotificationAuthorized, forKey: UserDefaultsKeys.isRequestAuthorizationGranted.rawValue)
        
        if isTerminating == true  {
            
        }
        
        else {
            
            
            /*
            // Checks for disconnects between what is displayed in the switches, what is stored in static variables and what is stored in user defaults
            print("shouldFollowUp \(NotificationConstant.shouldFollowUp) \(UserDefaults.standard.value(forKey: UserDefaultsKeys.shouldFollowUp.rawValue) as! Bool)")
            print("isAuthorized \(NotificationConstant.isNotificationAuthorized) \(UserDefaults.standard.value(forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue) as! Bool)")
            print("isEnabled \(NotificationConstant.isNotificationEnabled) \(UserDefaults.standard.value(forKey: UserDefaultsKeys.isNotificationEnabled.rawValue) as! Bool)")
            print("isPaused \(TimingManager.isPaused) \(UserDefaults.standard.value(forKey: UserDefaultsKeys.isPaused.rawValue) as! Bool)")
             */
             
            
            if NotificationConstant.isNotificationAuthorized && NotificationConstant.isNotificationEnabled && !TimingManager.isPaused {
                for dogKey in TimingManager.timerDictionary.keys{
                    
                    for requirementKey in TimingManager.timerDictionary[dogKey]!.keys{
                        guard TimingManager.timerDictionary[dogKey]![requirementKey]!.isValid else{
                            continue
                        }
                        Utils.willCreateUNUserNotification(dogName: dogKey, requirementName: requirementKey, executionDate: TimingManager.timerDictionary[dogKey]![requirementKey]!.fireDate)
                        if NotificationConstant.shouldFollowUp == true {
                            Utils.willCreateFollowUpUNUserNotification(dogName: dogKey, requirementName: requirementKey, executionDate: TimingManager.timerDictionary[dogKey]![requirementKey]!.fireDate + (60.0*5.0))
                        }
                        
                     }
                }
            }
            /*
             pending notif checker
            print("current date \(Date())")
             UNUserNotificationCenter.current().getPendingNotificationRequests { (notifs) in
                for notif in notifs{
                    print("\(notif.content.title)  \(notif.content.body)   \(notif.trigger?.description)")
                }
            }
             */
        }
    }
    
    static func willEnterForeground(){
        synchronizeNotificationAuthorization()
        
        if NotificationConstant.isNotificationAuthorized && NotificationConstant.isNotificationEnabled == true{
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        }
    }
    
    ///Checks to see if a change in notification permissions has occured, if it has then update to reflect
    static private func synchronizeNotificationAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { (permission) in
            switch permission.authorizationStatus {
            case .authorized:
                print(".authorized")
                
                //going from off to on, meaning the user has gone into the settings app and turned notifications from disabled to enabled
                if UserDefaults.standard.value(forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue) as! Bool == false {
                    UserDefaults.standard.setValue(true, forKey: UserDefaultsKeys.isNotificationEnabled.rawValue)
                    UserDefaults.standard.setValue(true, forKey: UserDefaultsKeys.shouldFollowUp.rawValue)
                    NotificationConstant.isNotificationEnabled = true
                    NotificationConstant.shouldFollowUp = true
                }
                
                UserDefaults.standard.setValue(true, forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue)
                NotificationConstant.isNotificationAuthorized = true
                
                
            case .denied:
                print(".denied")
                UserDefaults.standard.setValue(false, forKey: UserDefaultsKeys.isNotificationAuthorized.rawValue)
                UserDefaults.standard.setValue(false, forKey: UserDefaultsKeys.isNotificationEnabled.rawValue)
                UserDefaults.standard.setValue(false, forKey: UserDefaultsKeys.shouldFollowUp.rawValue)
                NotificationConstant.isNotificationAuthorized = false
                NotificationConstant.isNotificationEnabled = false
                NotificationConstant.shouldFollowUp = false
                //Updates switch to reflect change, if the last view open was the settings page then the app is exitted and property changed in the settings app then this app is reopened, VWL will not be called as the settings page was already opened, weird edge case.
                DispatchQueue.main.async {
                    let settingsVC: SettingsViewController? = MainTabBarViewController.mainTabBarViewController.settingsViewController
                    if settingsVC != nil && settingsVC!.isViewLoaded {
                        settingsVC?.refreshNotificationSwitches(animated: false)
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
        else if errorProcessorInstance.handleRequirementError(sender: sender, error: error) == true {
            return
        }
        else if errorProcessorInstance.handleRequirementManagerError(sender: sender, error: error) == true {
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
    
    ///Returns true if able to find a match in enum RequirementError to the error provided
    private func handleRequirementError(sender: Sender, error: Error) -> Bool{
        /*
         case nameInvalid
         case descriptionInvalid
         case intervalInvalid
         */
        if case RequirementError.nameInvalid = error {
            ErrorProcessor.alertForError(message: "Your dog's reminder name is invalid, please try a different one.")
            return true
        }
        else if case RequirementError.nameBlank = error {
            ErrorProcessor.alertForError(message: "Your reminder's name is blank, try typing something in.")
            return true
        }
        else if case RequirementError.descriptionInvalid = error {
            ErrorProcessor.alertForError(message: "Your dog's reminder description is invalid, please try a different one.")
            return true
        }
        else if case RequirementError.intervalInvalid = error {
            ErrorProcessor.alertForError(message: "Your dog's reminder countdown time is invalid, please try a different one.")
            return true
        }
        else{
            return false
        }
    }
    
    ///Returns true if able to find a match in enum RequirementManagerError to the error provided
    private func handleRequirementManagerError(sender: Sender, error: Error) -> Bool{
        /*
         case requirementAlreadyPresent
         case requirementNotPresent
         case requirementInvalid
         */
        if case RequirementManagerError.requirementAlreadyPresent = error {
            ErrorProcessor.alertForError(message: "Your reminder's name is already present, please try a different one.")
            return true
        }
        else if case RequirementManagerError.requirementNotPresent = error{
            ErrorProcessor.alertForError(message: "Could not find a match for your reminder!")
            return true
        }
        else if case RequirementManagerError.requirementInvalid = error {
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

class Sender {
    
    let origin: AnyObject?
    var localized: AnyObject?
    
    init(origin: AnyObject, localized: AnyObject){
        if origin is Sender{
            let castedSender = origin as! Sender
            self.origin = castedSender.origin
        }
        else {
            self.origin = origin
        }
        if localized is Sender {
            fatalError("localized cannot be sender")
        }
        else{
            self.localized = localized
        }
    }
    
}

//class CompletionHandler {
    
    
    
    /*
     
     //Implemention Example
     
     typealias CompletionHandler = (completed: Bool) -> Void
     
     func doSomthing(exampleParameter: String, completionHandler: CompletionHandler) {
     
        if exampleParameter = "correctString" {
            completionHandler(completed: true)
        }
        else {
            completionHandler(completed: false)
        }
     }
     
     //Use example
     
     doSomething(exampleParameter: "apple", { (completion) -> Void in
     
        if completion {
            //Success
        }
        else {
            //Failure
        }
     
     })
     
     
     
     //ABOVE CODE IS REWRITTEN FROM BELOW
     
     typealias CompletionHandler = (success:Bool) -> Void

     func downloadFileFromURL(url: NSURL,completionHandler: CompletionHandler) {

         // download code.

         let flag = true // true if download succeed,false otherwise

         completionHandler(success: flag)
     }

     // How to use it.

     downloadFileFromURL(NSURL(string: "url_str")!, { (success) -> Void in

         // When download completes,control flow goes here.
         if success {
             // download success
         } else {
             // download fail
         }
     })
     */
//}



