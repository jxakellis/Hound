//
//  Utils.swift
//  Pupotty
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
    static func willShowAlert(title: String, message: String?)
    {
        var trimmedMessage: String? = message
        if message!.trimmingCharacters(in: .whitespaces) == ""{
            trimmedMessage = nil
        }
        
        let alertController = GeneralAlertController(
            title: title,
            message: trimmedMessage,
            preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        
        alertController.addAction(alertAction)
        
        AlertPresenter.shared.enqueueAlertForPresentation(alertController)
        
    }
    
    static func willCreateFollowUpUNUserNotification(dogName: String, requirementName: String, executionDate: Date){
        //let requirement = try! MainTabBarViewController.staticDogManager.findDog(dogName: dogName).dogRequirments.findRequirement(requirementName: requirementName)
        
         let content = UNMutableNotificationContent()
        
         content.title = "Follow up reminder for \(dogName)!"
        
        content.body = "It's been \(String.convertToReadable(interperateTimeInterval: NotificationConstant.followUpDelay, capitalizeLetters: false)), give your dog a helping hand!"
        
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
         content.title = "Reminder for \(dogName)!"
        
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


class ErrorProcessor{
    
    ///Alerts for an error, just calls Utils.willShowAlert currently with a specified title of "Error"
    static func alertForError(message: String){
        
        Utils.willShowAlert(title: "🚨Error🚨", message: message)
        
    }
    
    private static func alertForErrorProcessor(sender: Sender, message: String){
        let originTest = sender.origin
        if originTest != nil{
            Utils.willShowAlert(title: "🚨Error from \(NSStringFromClass(originTest!.classForCoder))🚨", message: message)
        }
        else {
            Utils.willShowAlert(title: "🚨Error from unknown class🚨", message: message)
        }
        
    }
    
    ///Handles a given error, uses helper functions to compare against all known (custom) error types
    static func handleError(sender: Sender, error: Error){
        
        let errorProcessorInstance = ErrorProcessor()
        
        if errorProcessorInstance.handleTimingManagerError(sender: sender, error: error) == true {
            return
        }
        else if errorProcessorInstance.handleDogManagerError(sender: sender, error: error) == true{
            return
        }
        else if errorProcessorInstance.handleDogError(sender: sender, error: error) == true{
            return
        }
        else  if errorProcessorInstance.handleDogTraitManagerError(sender: sender, error: error) == true {
            return
        }
        else if errorProcessorInstance.handleArbitraryLogError(sender: sender, error: error) == true {
            return
        }
        else if errorProcessorInstance.handleRequirementManagerError(sender: sender, error: error) == true {
            return
        }
        else if errorProcessorInstance.handleRequirementError(sender: sender, error: error) == true {
            return
        }
        else if errorProcessorInstance.handleTimeOfDayComponentsError(sender: sender, error: error) == true {
            return
        }
        else if errorProcessorInstance.handleStringExtensionError(sender: sender, error: error) == true {
            return
        }
        else {
            ErrorProcessor.alertForErrorProcessor(sender: sender, message: "Unable to desifer error of description: \(error.localizedDescription)")
        }
    }
    
    ///Returns true if able to find a match in enum TimingManagerError to the error provided
    private func handleTimingManagerError(sender: Sender, error: Error) -> Bool{
        /*
         enum TimingManagerError: Error{
             case parseSenderInfoFailed
             case invalidateFailed
         }
         */
        if case TimingManagerError.invalidateFailed = error {
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
    
    ///Returns true if able to find a match in enum DogManagerError to the error provided
    private func handleDogManagerError(sender: Sender, error: Error) -> Bool{
        /*
         enum DogManagerError: Error{
             case dogNameBlank
             case dogNameInvalid
             case dogNameNotPresent
             case dogNameAlreadyPresent
         }
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
    
    ///Returns true if able to find a match in enum DogError to the error provided
    private func handleDogError(sender: Sender, error: Error) -> Bool{
        /*
         enum DogError: Error {
             case noRequirementsPresent
         }
         */
        if case DogError.noRequirementsPresent = error {
            ErrorProcessor.alertForError(message: "Your dog has no reminders, please try adding one.")
            return true
        }
        else{
            return false
        }
    }
    
    ///Returns true if able to find a match in enum DogTraitManagerError to the error provided
    private func handleDogTraitManagerError(sender: Sender, error: Error) -> Bool{
        /*
         enum DogTraitManagerError: Error{
             case nilName
             case blankName
             case invalidName
         }
         */
        if case DogTraitManagerError.nilName = error {
            ErrorProcessor.alertForError(message: "Your dog has an invalid name, try typing something else in!")
            return true
        }
        else if case DogTraitManagerError.blankName = error {
            ErrorProcessor.alertForError(message: "Your dog has a blank name, try typing something in!")
            return true
        }
        else if case DogTraitManagerError.invalidName = error {
            ErrorProcessor.alertForError(message: "Your dog has a invalid name, try typing something else in!")
            return true
        }
        else {
            return false
        }
    }
    
    ///Returns true if able to find a match in enum ArbitraryLogError to the error provided
    private func handleArbitraryLogError(sender: Sender, error: Error) -> Bool {
        /*
         enum ArbitraryLogError: Error {
             case nilLogName
             case blankLogName
         }
         */
        if case ArbitraryLogError.nilLogName = error {
            ErrorProcessor.alertForError(message: "Your arbitrary log has no name, please try putting one in.")
            return true
        }
        else if case ArbitraryLogError.blankLogName = error {
            ErrorProcessor.alertForError(message: "Your arbitrary log has a blank name, please try putting typing one in.")
            return true
        }
        else{
            return false
        }
    }
    
    ///Returns true if able to find a match in enum RequirementManagerError to the error provided
    private func handleRequirementManagerError(sender: Sender, error: Error) -> Bool{
        /*
         enum RequirementManagerError: Error {
            case requirementAlreadyPresent
             case requirementNotPresent
             case requirementInvalid
             case requirementNameNotPresent
         }
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
        else if case RequirementManagerError.requirementNameNotPresent = error {
            ErrorProcessor.alertForError(message: "Your reminder couldn't be located while attempting to modify its data")
            return true
        }
        else{
            return false
        }
    }
    
    ///Returns true if able to find a match in enum RequirementError to the error provided
    private func handleRequirementError(sender: Sender, error: Error) -> Bool{
        /*
         enum RequirementError: Error {
             case nameBlank
             case nameInvalid
             case descriptionInvalid
             case intervalInvalid
         }
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
    
    ///Returns true if able to find a match in enum TimeOfDayComponentsError to the error provided
    private func handleTimeOfDayComponentsError(sender: Sender, error: Error) -> Bool{
        /*
         enum TimeOfDayComponentsError: Error {
             case invalidCalendarComponent
             case invalidWeekdayArray
         }
         */
        if case TimeOfDayComponentsError.invalidCalendarComponent = error {
            ErrorProcessor.alertForError(message: "Invalid Calendar Components")
            return true
        }
        else if case TimeOfDayComponentsError.invalidWeekdayArray = error {
            ErrorProcessor.alertForError(message: "Please select atleast one weekday for the reminder to go off on.")
            return true
        }
        else {
            return false
        }
    }
    
    private func handleStringExtensionError(sender: Sender, error: Error) -> Bool{
        /*
         enum StringExtensionError: Error {
             case invalidDateComponents
         }
         */
        if case StringExtensionError.invalidDateComponents = error {
            ErrorProcessor.alertForError(message: "Invalid dateComponent passed to String extension.")
            return true
        }
        else {
            return false
        }
    }
    
}


