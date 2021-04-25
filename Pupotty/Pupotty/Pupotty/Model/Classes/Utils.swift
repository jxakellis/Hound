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
        else if case TimeOfDayComponentsError.invalidCalendarComponent = error {
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
}


