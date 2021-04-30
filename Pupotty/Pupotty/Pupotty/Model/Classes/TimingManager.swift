//
//  Timing.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 11/20/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol TimingManagerDelegate {
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager)
}

class TimingManager{
    
    //MARK: - Properties
    
    static var delegate: TimingManagerDelegate! = nil
    
    ///Saves state isPaused, self.isPaused can be modified by SettingsViewController but this is only when there are no active timers and pause is automatically set to unpaused
    static var isPaused: Bool = false
    ///Saves date of last pause (if there was one)
    static var lastPause: Date? = nil
    ///Saves date of last unpause (if there was one)
    static var lastUnpause: Date? = nil
    
    ///Returns number of active timers, returns nil if paused
    static var currentlyActiveTimersCount: Int? {
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
    
    ///If a timeOfDay alarm is being skipped, this array stores all the timers that are responsible for unskipping the alarm when it goes from 1 Day -> 23 Hours 59 Minutes
    private static var isSkippingDisablers: [Timer] = []
    //MARK: - Main
    
    ///Initalizes all timers according to the dogManager passed, assumes no timers currently active and if transitioning from Paused to Unpaused (didUnpuase = true) handles logic differently
    static func willInitalize(dogManager: DogManager){
        ///Takes a DogManager and potentially a Bool of if all timers were unpaused, goes through the dog manager and finds all enabled requirements under all enabled dogs and sets a timer to fire.
        
        //Makes sure isPaused is false, don't want to instantiate timers when they should be paused
        guard self.isPaused == false else {
            return
        }
        
        //goes through all dogs
        for d in 0..<dogManager.dogs.count{
            //makes sure current dog is enabled, as if it isn't then all of its timers arent either
            guard dogManager.dogs[d].getEnable() == true else {
                continue
            }
            
            //goes through all requirements in a dog
            for r in 0..<dogManager.dogs[d].dogRequirments.requirements.count{
                
                let requirement = dogManager.dogs[d].dogRequirments.requirements[r]
                
                
                
                //makes sure a requirement is enabled and its presentation is not being handled
                guard requirement.getEnable() == true && requirement.isPresentationHandled == false
                else{
                    continue
                }
                /*
                print("TM")
                print(Date())
                print("skipping \(requirement.timeOfDayComponents.isSkipping)")
                print("exe basis \(requirement.executionBasis)")
                print("exe date \(requirement.executionDate)")
                print("trad \(requirement.timeOfDayComponents.traditionalNextTimeOfDay(executionBasis: requirement.executionBasis))")
                print("skip \(requirement.timeOfDayComponents.skippingNextTimeOfDay(executionBasis: requirement.executionBasis))")
                print("next \(requirement.timeOfDayComponents.nextTimeOfDay(requirementExecutionBasis: requirement.executionBasis))")
                */
                //Sets a timer that executes when the timer should go from isSkipping true -> false, e.g. 1 Day left on a timer that is skipping and when it hits 23 hours and 59 minutes it turns into a regular nonskipping timer
                let unskipDate = requirement.timeOfDayComponents.unskipDate(timerMode: requirement.timerMode, requirementExecutionBasis: requirement.executionBasis)
                if unskipDate != nil {
                    let isSkippingDisabler = Timer(fireAt: unskipDate!,
                                                 interval: -1,
                                                 target: self,
                                                 selector: #selector(self.willUpdateIsSkipping(sender:)),
                                                 userInfo: ["dogName": dogManager.dogs[d].dogTraits.dogName, "requirement": requirement, "dogManager": dogManager],
                                                 repeats: false)
                    isSkippingDisablers.append(isSkippingDisabler)
                    RunLoop.main.add(isSkippingDisabler, forMode: .common)
                }
                
                var timer: Timer!
                
                //active
                if requirement.isActive == true {
                    timer = Timer(fireAt: requirement.executionDate!,
                                          interval: -1,
                                          target: self,
                                          selector: #selector(self.didExecuteTimer(sender:)),
                                          userInfo: ["dogName": dogManager.dogs[d].dogTraits.dogName, "requirement": requirement],
                                          repeats: false)
                    RunLoop.main.add(timer, forMode: .common)
                }
                
                //inactive, still adds to the runloop as the timer execution date and number of timers is used for many functions
                else {
                    timer = Timer(fireAt: requirement.executionDate!,
                                          interval: -1,
                                          target: self,
                                          selector: #selector(self.sudoSelector),
                                          userInfo: nil,
                                          repeats: false)
                }
                
                
                //Updates timerDictionary to reflect new timer added, this is so a reference to the created timer can be referenced later and invalidated if needed.
                var nestedtimerDictionary: Dictionary<String, Timer> = timerDictionary[dogManager.dogs[d].dogTraits.dogName] ?? Dictionary<String,Timer>()
                
                nestedtimerDictionary[requirement.requirementName] = timer
                
                timerDictionary[dogManager.dogs[d].dogTraits.dogName] = nestedtimerDictionary
            }
        }
    }
    
    ///Dummy selector sent to an inactive timer, an inactive timer (due to the way the infrastructure is built) still needs to be added to the timer dictionary so dependent components can display information properly
    @objc static private func sudoSelector(){
    }
    
    ///Invalidates all current timers then calls willInitalize, makes it a clean slate then re sets everything up
    static func willReinitalize(dogManager: DogManager) {
        ///Reinitalizes all timers when a new dogManager is sent
        self.invalidateAll()
        self.willInitalize(dogManager: dogManager)
    }
    
    
    ///If a requirement is skipping the next time of day alarm, at some point it will go from 1+ day away to 23 hours and 59 minutes. When that happens then the timer should be changed from isSkipping to normal mode because it just skipped that alarm that should have happened
    @objc private static func willUpdateIsSkipping(sender: Timer){
        guard let parsedDictionary = sender.userInfo as? [String: Any]
        else{
            ErrorProcessor.handleError(sender: Sender(origin: self, localized: self), error: TimingManagerError.parseSenderInfoFailed)
            return
        }
        let dogName: String = parsedDictionary["dogName"]! as! String
        let requirementName: String = (parsedDictionary["requirement"]! as! Requirement).requirementName
        
        //DogManagerEfficencyImprovement let sudoDogManager = MainTabBarViewController.staticDogManager.copy() as! DogManager
        let dogManager = MainTabBarViewController.staticDogManager
        let requirement = try! dogManager.findDog(dogName: dogName).dogRequirments.findRequirement(requirementName: requirementName)
        
        requirement.timeOfDayComponents.changeIsSkipping(newSkipStatus: false)
        requirement.changeExecutionBasis(newExecutionBasis: Date(), shouldResetIntervalsElapsed: true)
        
        delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), newDogManager: dogManager)
    }
    
    //MARK: - Pause Control
    
    ///Toggles pause for a given dogManager to a specifided newPauseState
    static func willTogglePause(dogManager: DogManager, newPauseStatus: Bool) {
        
        //self.isPaused can be modified by SettingsViewController but this is only when there are no active timers and pause is automatically set to unpaused
        
        guard newPauseStatus != self.isPaused else {
            return
        }
        
        ///Toggles pause status of timers, called when pauseAllTimers in settings is switched to a new state
        if newPauseStatus == true {
            self.lastPause = Date()
            self.isPaused = true
            
            willPause(dogManager: dogManager)
            
            invalidateAll()
            
        }
        else {
            self.lastUnpause = Date()
            self.isPaused = false
            willUnpause(dogManager: dogManager)
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
        
        for timerIndex in 0..<isSkippingDisablers.count {
            isSkippingDisablers[timerIndex].invalidate()
        }
        
        isSkippingDisablers.removeAll()
        
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
    
    ///Updates dogManager to reflect the changes in intervalElapsed as if everything is paused the amount of time elapsed by each timer must to saved so when unpaused the new timers can be properly calculated
    private static func willPause(dogManager: DogManager){
        for dogKey in timerDictionary.keys{
            for requirementKey in timerDictionary[dogKey]!.keys {
                
                //checks to make sure the enabled timer found is still valid (invalid ones are just ones from the past, left in the data)
                guard timerDictionary[dogKey]![requirementKey]!.isValid else {
                    continue
                }
                
                let requirement = try! dogManager.findDog(dogName: dogKey).dogRequirments.findRequirement(requirementName: requirementKey)
                
                //If requirement is counting down
                if requirement.timerMode == .countDown {
                    //If intervalElapsed has not been added to before
                    if requirement.countDownComponents.intervalElapsed <= 0.0001 {
                        requirement.countDownComponents.changeIntervalElapsed(newIntervalElapsed: requirement.executionBasis.distance(to: self.lastPause!))
                    }
                    //If intervalElapsed has been added to before
                    else{
                        
                        requirement.countDownComponents.changeIntervalElapsed(newIntervalElapsed: (requirement.countDownComponents.intervalElapsed + self.lastUnpause!.distance(to: (self.lastPause!))))
                    }
                }
                //If requirement is snoozed
                else if requirement.timerMode == .snooze {
                    //If intervalElapsed has not been added to before
                    if requirement.snoozeComponents.intervalElapsed <= 0.0001 {
                        requirement.snoozeComponents.changeIntervalElapsed(newIntervalElapsed: requirement.executionBasis.distance(to: self.lastPause!))
                    }
                    //If intervalElapsed has been added to before
                    else{
                        requirement.snoozeComponents.changeIntervalElapsed(newIntervalElapsed: (requirement.snoozeComponents.intervalElapsed + self.lastUnpause!.distance(to: (self.lastPause!))))
                    }
                }
                //If requirement is time of day
                else if requirement.timerMode == .timeOfDay{
                    //nothing as time of day does not utilize interval elapsed
                }
                else {
                    fatalError("Not Implemented")
                }
                
                
                
            }
        }
        
        delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), newDogManager: dogManager)
    }
    
    ///Updates dogManager to reflect needed changes to the executionBasis, without this change the interval remaining would be based off an incorrect start date and fire at the wrong time. Can't use just Date() as it would be inaccurate if reinitalized but executionBasis + intervalRemaining will yield the same executionDate everytime.
    private static func willUnpause(dogManager: DogManager){
        
        //Goes through all enabled dogs and all their enabled requirements
        for dog in dogManager.dogs{
            guard dog.getEnable() == true else {
                continue
            }
            for requirement in dog.dogRequirments.requirements {
                
                guard requirement.getEnable() == true else {
                    continue
                }
                
                //Changes the execution basis to the current time of unpause, if the execution basis is not changed then the interval remaining will go off a earlier point in time and have an overall earlier execution date, making the timer fire too early
                requirement.changeExecutionBasis(newExecutionBasis: Date(), shouldResetIntervalsElapsed: false)
                
                
            }
        }
        
        delegate.didUpdateDogManager(sender: Sender(origin: self, localized: self), newDogManager: dogManager)
    }

    //MARK: - Timer Actions
    
    ///Used as a selector when constructing timer in willInitalize, when called at an unknown point in time by the timer it triggers helper functions to create both in app notifcations and iOS notifcations
    @objc private static func didExecuteTimer(sender: Timer){
        
        //Parses the sender info needed to figure out which requirement's timer fired
        guard let parsedDictionary = sender.userInfo as? [String: Any]
        else{
            ErrorProcessor.handleError(sender: Sender(origin: self, localized: self), error: TimingManagerError.parseSenderInfoFailed)
            return
        }
        
        let dogName: String = parsedDictionary["dogName"]! as! String
        let requirement: Requirement = parsedDictionary["requirement"]! as! Requirement
        
        TimingManager.willShowTimer(dogName: dogName, requirement: requirement)
    }
    
    ///Creates alertController to queue for presentation along with information passed along with it to reinitalize the timer once an option is selected (e.g. disable or snooze)
    static func willShowTimer(sender: Sender = Sender(origin: Utils.presenter, localized: Utils.presenter), dogName: String, requirement: Requirement){
        
        let title = "\(requirement.requirementName) - \(dogName)"
        let message = "\(requirement.requirementDescription)"
        
        let alertController = AlarmAlertController(
            title: title,
            message: message,
            preferredStyle: .alert)
        
        let alertActionDismiss = UIAlertAction(
            title:"Dismiss",
            style: .cancel,
            handler:
                {
                    (alert: UIAlertAction!)  in
                    //Do not provide dogManager as in the case of multiple queued alerts, if one alert is handled the next one will have an outdated dogManager and when that alert is then handled it pushes its outdated dogManager which completely messes up the first alert and overrides any choices made about it; leaving a un initalized but completed timer.
                    TimingManager.willInactivateTimer(sender: Sender(origin: self, localized: self), dogName: dogName, requirementName: requirement.requirementName)
                })
        
        let alertActionDone = UIAlertAction(
            title:"Did it!",
            style: .default,
            handler:
                {
                    (alert: UIAlertAction!)  in
                    //Do not provide dogManager as in the case of multiple queued alerts, if one alert is handled the next one will have an outdated dogManager and when that alert is then handled it pushes its outdated dogManager which completely messes up the first alert and overrides any choices made about it; leaving a un initalized but completed timer.
                    TimingManager.willResetTimer(sender: Sender(origin: self, localized: self), dogName: dogName, requirementName: requirement.requirementName)
                })
        
        let alertActionSnooze = UIAlertAction(
            title:"Snooze",
            style: .default,
            handler:
                {
                    (alert: UIAlertAction!)  in
                    //Do not provide dogManager as in the case of multiple queued alerts, if one alert is handled the next one will have an outdated dogManager and when that alert is then handled it pushes its outdated dogManager which completely messes up the first alert and overrides any choices made about it; leaving a un initalized but completed timer.
                    TimingManager.willSnoozeTimer(sender: Sender(origin: self, localized: self), dogName: dogName, requirementName: requirement.requirementName, isCancellingSnooze: false)
                })
        alertController.addAction(alertActionDone)
        alertController.addAction(alertActionSnooze)
        alertController.addAction(alertActionDismiss)
        
    
        //DogManagerEfficencyImprovement let sudoDogManager = MainTabBarViewController.staticDogManager.copy() as! DogManager
        let dogManager = MainTabBarViewController.staticDogManager
        let requirement = try! dogManager.findDog(dogName: dogName).dogRequirments.findRequirement(requirementName: requirement.requirementName)
        
        if requirement.isPresentationHandled == false {
            requirement.isPresentationHandled = true
            delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), newDogManager: dogManager)
        }
        
        AlertPresenter.shared.enqueueAlertForPresentation(alertController)
        
    }
    
    ///Finishes executing timer and then disables it, note passed requirement should be a reference to a requirement in passed dogManager
    static func willDisableTimer(sender: Sender, dogName targetDogName: String, requirementName targetRequirementName: String, dogManager: DogManager = MainTabBarViewController.staticDogManager){
        
        
            if TimingManager.timerDictionary[targetDogName]![targetRequirementName]!.isValid == true {
                TimingManager.timerDictionary[targetDogName]![targetRequirementName]!.invalidate()
            }
        
        let requirement = try! dogManager.findDog(dogName: targetDogName).dogRequirments.findRequirement(requirementName: targetRequirementName)
        
        requirement.timerReset(shouldLogExecution: true)
        
        requirement.setEnable(newEnableStatus: false)
        
        delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), newDogManager: dogManager)
    }
    
    ///Finishes executing timer and then sets its isSnoozed to true, note passed requirement should be a reference to a requirement in passed dogManager
    static func willSnoozeTimer(sender: Sender, dogName targetDogName: String, requirementName targetRequirementName: String, isCancellingSnooze: Bool, dogManager: DogManager = MainTabBarViewController.staticDogManager){
        let requirement = try! dogManager.findDog(dogName: targetDogName).dogRequirments.findRequirement(requirementName: targetRequirementName)
        
        let newSnoozeStatus = !isCancellingSnooze
        
        requirement.timerReset(shouldLogExecution: false)
        
        requirement.snoozeComponents.changeSnooze(newSnoozeStatus: newSnoozeStatus)
        
        delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), newDogManager: dogManager)
    }
    
    ///Finishs executing timer then just resets it to countdown again
    static func willResetTimer(sender: Sender, dogName targetDogName: String, requirementName targetRequirementName: String, dogManager: DogManager = MainTabBarViewController.staticDogManager){
        
        let sudoDogManager = dogManager
        
        let requirement = try! sudoDogManager.findDog(dogName: targetDogName).dogRequirments.findRequirement(requirementName: targetRequirementName)
        
        //inactive to active
        if requirement.isActive == false{
            requirement.changeActiveStatus(newActiveStatus: true)
        }
        //Skips next TOD
        else if requirement.timerMode == .timeOfDay && requirement.timeOfDayComponents.isSkipping == false && Date().distance(to: TimingManager.timerDictionary[targetDogName]![targetRequirementName]!.fireDate) > 0{
            let executionBasisBackup = requirement.executionBasis
            requirement.timerReset(shouldLogExecution: true)
            requirement.timeOfDayComponents.changeIsSkipping(newSkipStatus: true)
            requirement.changeExecutionBasis(newExecutionBasis: executionBasisBackup, shouldResetIntervalsElapsed: false)
        }
        //Unskips next TOD
        else if requirement.timerMode == .timeOfDay && requirement.timeOfDayComponents.isSkipping == true{
            requirement.timeOfDayComponents.changeIsSkipping(newSkipStatus: false)
           // if requirement.logDates.isEmpty == false {
             //   requirement.logDates.removeLast()
           // }
        }
        //Regular reset
        else {
            requirement.timerReset(shouldLogExecution: true)
        }
        
        delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), newDogManager: sudoDogManager)
    }
    
    ///If dismiss is clicked when a timer fires and its pop of choices shows, it puts the timer into a disable like state. It still shows on the home screen and can be clicked on but remains inactive with no future timers.
    static func willInactivateTimer(sender: Sender, dogName targetDogName: String, requirementName targetRequirementName: String, dogManager: DogManager = MainTabBarViewController.staticDogManager){
        
        
        let requirement = try! dogManager.findDog(dogName: targetDogName).dogRequirments.findRequirement(requirementName: targetRequirementName)
        
        requirement.changeActiveStatus(newActiveStatus: false)
        
    }
    
    
}
