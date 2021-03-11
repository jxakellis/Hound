//
//  Timing.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 11/20/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol TimingManagerDelegate {
    func didUpdateDogManager(newDogManager: DogManager, sender: AnyObject?)
}

class TimingManager{
    
    //MARK: MAIN
    
    static var delegate: TimingManagerDelegate! = nil
    
    ///Saves state isPaused
    static var isPaused: Bool = false
    ///Saves date of last pause (if there was one)
    static var lastPause: Date?
    ///Saves date of last unpause (if there was one)
    static var lastUnpause: Date?
    
    ///Returns number of active timers
    static var activeTimers: Int?{
        
        guard isPaused == false else {
            return nil
        }
        
        var count = 0
        for d in 0..<MainTabBarViewController.staticDogManager.dogs.count {
            guard MainTabBarViewController.staticDogManager.dogs[d].getEnable() == true else{
                continue
            }
            
            for r in 0..<MainTabBarViewController.staticDogManager.dogs[d].dogRequirments.requirements.count {
                guard MainTabBarViewController.staticDogManager.dogs[d].dogRequirments.requirements[r].getEnable() == true else{
                    continue
                }
                
                count = count + 1
            }
        }
        return count
        
    }
    
    ///Corrolates to dogManager: "
    ///Dictionary<dogName: String, Dictionary<requirementName: String, associatedTimer: Timer>>"
    
    /// IMPORTANT NOTE: DO NOT COPY, WILL MAKE MULTIPLE TIMERS WHICH WILL FIRE SIMULTANIOUSLY
    static var timerDictionary: Dictionary<String,Dictionary<String,Timer>> = Dictionary<String,Dictionary<String,Timer>>()
    
    //MARK: TimingProtocol Implementation
    
    ///Initalizes all timers according to the dogManager passed, assumes no timers currently active and if transitioning from Paused to Unpaused (didUnpuase = true) handles logic differently
    static func willInitalize(dogManager: DogManager, didUnpause: Bool = false){
        ///Takes a DogManager and potentially a Bool of if all alarms were unpaused, goes through the dog manager and finds all enabled requirements under all enabled dogs and sets a timer to fire.
        
        //Makes sure pauseAllAlarms is false, don't want to instantiate alarms when they should be paused
        guard self.isPaused == false else {
            return
        }
        
        //goes through all dogs
        for d in 0..<dogManager.dogs.count{
            //makes sure current dog is enabled, as if it isn't then all of its alarms arent either
            guard dogManager.dogs[d].getEnable() == true else {
                continue
            }
            
            //goes through all requirements in a dog
            for r in 0..<dogManager.dogs[d].dogRequirments.requirements.count{
                
                let requirement = dogManager.dogs[d].dogRequirments.requirements[r]
                
                //makes sure a requirement is enabled
                guard requirement.getEnable() == true
                else{
                    continue
                }
                
                var executionDate: Date! = nil
                
                //If transitioning from paused to unpaused, calculates execution date differently, this is because the alarm elasped an amount of time before it was paused, so it only has its interval minus the time elapsed left to go.
                if didUnpause == true {
                    
                    var intervalLeft: TimeInterval! = nil
                    
                    intervalLeft = requirement.activeInterval - requirement.intervalElapsed
                    
                    executionDate = Date.executionDate(lastExecution: Date(), interval: intervalLeft)
                    
                    //debug info
                    //print("originalDate: \(pauseState.2)  pausedDate: \(pauseState.0!) currentDate: \(Date()) intervalElapsed: \(intervalElapsed.description) intervalLeft: \(intervalLeft.description) executionDate: \(executionDate.description)")
                    
                }
                
                //If not transitioning from unpaused, calculates execution date traditionally
                else if didUnpause == false{
                    executionDate = Date.executionDate(lastExecution: requirement.lastExecution, interval: requirement.activeInterval)
                }
                
                let timer = Timer(fireAt: executionDate,
                                  interval: -1,
                                  target: self,
                                  selector: #selector(self.didExecuteTimer(sender:)),
                                  userInfo: try! ["dogName": dogManager.dogs[d].dogSpecifications.getDogSpecification(key: "name"), "requirement": requirement, "dogManager": dogManager],
                                  repeats: false)
                
                //Updates timerDictionary to reflect new alarm added, this is so a reference to the created timer can be referenced later and invalidated if needed.
                var nestedtimerDictionary: Dictionary<String, Timer> = try! timerDictionary[dogManager.dogs[d].dogSpecifications.getDogSpecification(key: "name")] ?? Dictionary<String, Timer>()
                
                nestedtimerDictionary[requirement.name] = timer
                
                try! timerDictionary[dogManager.dogs[d].dogSpecifications.getDogSpecification(key: "name")] = nestedtimerDictionary
                
                if Date().distance(to: executionDate) < 0 {
                    if requirement.isPresentationHandled == true {
                        continue
                    }
                }
                
                RunLoop.main.add(timer, forMode: .common)
                
            }
        }
    }
    
    ///Invalidates all current timers then calls willInitalize, makes it a clean slate then re sets everything up
    static func willReinitalize(dogManager: DogManager) {
        ///Reinitalizes all alarms when a new dogManager is sent
        self.invalidateAll()
        self.willInitalize(dogManager: dogManager)
    }
    
    ///Not implented currently
    static func willReinitalize(dogName: String, requirementName: String) throws {
        
    }
    
    ///Toggles pause for a given dogManager to a specifided newPauseState
    static func willTogglePause(dogManager: DogManager, newPauseStatus: Bool) {
        ///Toggles pause status of timers, called when pauseAllAlarms in settings is switched to a new state
        if newPauseStatus == true {
            self.lastPause = Date()
            self.isPaused = true
            
            willPause(dogManager: dogManager)
            
            invalidateAll()
            
        }
        else {
            self.lastUnpause = Date()
            self.isPaused = false
            willInitalize(dogManager: dogManager, didUnpause: true)
        }
    }
    
    
    ///Invalidates all timers
    private static func invalidateAll() {
        ///Invalidates all timers
        for dogKey in timerDictionary.keys{
            for requirementKey in timerDictionary[dogKey]!.keys {
                timerDictionary[dogKey]![requirementKey]!.invalidate()
            }
        }
    }
    
    ///Invalidates a given timer, located using dogName and requirementName, can throw if timer not found
    private static func invalidate(dogName: String, requirementName: String) throws {
        ///Invalidates a specific timer
        if timerDictionary[dogName] == nil{
            throw TimingManagerError.invalidateFailed
        }
        if timerDictionary[dogName]![requirementName] == nil {
            throw TimingManagerError.invalidateFailed
        }
        timerDictionary[dogName]![requirementName]!.invalidate()
    }
    
    ///Updates dogManager to reflect the changes in intervalElapsed as if everything is paused the amount of time elapsed by each alarm must to saved so when unpaused the new timers can be properly calculated
    private static func willPause(dogManager: DogManager){
        let sudoDogManager = dogManager
        for dogKey in timerDictionary.keys{
            for requirementKey in timerDictionary[dogKey]!.keys {
                
                var sudoRequirement = try! sudoDogManager.findDog(dogName: dogKey).dogRequirments.findRequirement(requirementName: requirementKey)
                
                if sudoRequirement.intervalElapsed <= 0.01 {
                    sudoRequirement.changeIntervalElapsed(newIntervalElapsed: sudoRequirement.lastExecution.distance(to: self.lastPause!))
                }
                else{
                    sudoRequirement.changeIntervalElapsed(newIntervalElapsed: (sudoRequirement.intervalElapsed + self.lastUnpause!.distance(to: (self.lastPause!))))
                }
                
            }
        }
        
        delegate.didUpdateDogManager(newDogManager: sudoDogManager, sender: self)
    }
    
    ///Used as a selector when constructing timer in willInitalize, when called at an unknown point in time by the timer it triggers helper functions to create both in app notifcations and iOS notifcations
    @objc private static func didExecuteTimer(sender: Timer){
        
        guard let parsedDictionary = sender.userInfo as? [String: Any]
        else{
            ErrorProcessor.handleError(error: TimingManagerError.parseSenderInfoFailed, sender: self)
            return
        }
        
        let dogName: String = parsedDictionary["dogName"]! as! String
        let requirement: Requirement = parsedDictionary["requirement"]! as! Requirement
        
        TimingManager.willShowTimer(dogName: dogName, requirement: requirement)
    }
    
    ///Creates alertController to queue for presentation along with information passed along with it to reinitalize the alarm once an option is selected (e.g. disable or snooze)
    private static func willShowTimer(sender: AnyObject = Utils.presenter, dogName: String, requirement: Requirement){
        
        let title = "\(requirement.name) - \(dogName)"
        let message = " \(requirement.requirementDescription)"
        
        let alertController = CustomAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        
        let alertActionDone = UIAlertAction(
            title:"Did it!",
            style: .cancel,
            handler:
                {
                    (alert: UIAlertAction!)  in
                    //Do not provide dogManager as in the case of multiple queued alerts, if one alert is handled the next one will have an outdated dogManager and when that alert is then handled it pushes its outdated dogManager which completely messes up the first alert and overrides any choices made about it; leaving a un initalized but completed timer.
                    TimingManager.willResetAlarm(dogName: dogName, requirementName: requirement.name)
                })
        let alertActionSnooze = UIAlertAction(
            title:"Snooze",
            style: .default,
            handler:
                {
                    (alert: UIAlertAction!)  in
                    //Do not provide dogManager as in the case of multiple queued alerts, if one alert is handled the next one will have an outdated dogManager and when that alert is then handled it pushes its outdated dogManager which completely messes up the first alert and overrides any choices made about it; leaving a un initalized but completed timer.
                    TimingManager.willSnoozeAlarm(dogName: dogName, requirementName: requirement.name)
                })
        let alertActionDisable = UIAlertAction(
            title:"Disable",
            style: .destructive,
            handler:
                {
                    (alert: UIAlertAction!)  in
                    //Do not provide dogManager as in the case of multiple queued alerts, if one alert is handled the next one will have an outdated dogManager and when that alert is then handled it pushes its outdated dogManager which completely messes up the first alert and overrides any choices made about it; leaving a un initalized but completed timer.
                    TimingManager.willDisableAlarm(dogName: dogName, requirementName: requirement.name)
                })
        alertController.addAction(alertActionDone)
        alertController.addAction(alertActionSnooze)
        alertController.addAction(alertActionDisable)
        
        let sudoDogManager = MainTabBarViewController.staticDogManager.copy() as! DogManager
        try! sudoDogManager.findDog(dogName: dogName).dogRequirments.findRequirement(requirementName: requirement.name).isPresentationHandled = true
        delegate.didUpdateDogManager(newDogManager: sudoDogManager, sender: self)
        
        AlertPresenter.shared.enqueueAlertForPresentation(alertController)
        
    }
    
    ///Finishes executing alarm and then disables it, note passed requirement should be a reference to a requirement in passed dogManager
    static func willDisableAlarm(dogName targetDogName: String, requirementName targetRequirementName: String, dogManager: DogManager = MainTabBarViewController.staticDogManager){
        
        if TimingManager.timerDictionary[targetDogName]![targetRequirementName]!.isValid == true {
            TimingManager.timerDictionary[targetDogName]![targetRequirementName]!.invalidate()
        }
        
        var requirement = try! dogManager.findDog(dogName: targetDogName).dogRequirments.findRequirement(requirementName: targetRequirementName)
        
        requirement.timerReset()
        
        requirement.setEnable(newEnableStatus: false)
        
        delegate.didUpdateDogManager(newDogManager: dogManager, sender: self)
    }
    
    ///Finishes executing alarm and then sets its isSnoozed to true, note passed requirement should be a reference to a requirement in passed dogManager
    static func willSnoozeAlarm(dogName targetDogName: String, requirementName targetRequirementName: String, dogManager: DogManager = MainTabBarViewController.staticDogManager){
        var requirement = try! dogManager.findDog(dogName: targetDogName).dogRequirments.findRequirement(requirementName: targetRequirementName)
        
        requirement.timerReset()
        
        requirement.changeSnooze(newSnoozeStatus: true)
        
        delegate.didUpdateDogManager(newDogManager: dogManager, sender: self)
    }
    
    ///Finishs executing alarm then just resets it to countdown again
    static func willResetAlarm(dogName targetDogName: String, requirementName targetRequirementName: String, dogManager: DogManager = MainTabBarViewController.staticDogManager){
        let sudoDogManager = dogManager
        
        var requirement = try! sudoDogManager.findDog(dogName: targetDogName).dogRequirments.findRequirement(requirementName: targetRequirementName)
        
        requirement.timerReset()
        
        delegate.didUpdateDogManager(newDogManager: sudoDogManager, sender: self)
    }
    
    
}
