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

class TimingManager: TimingProtocol {
    
    //MARK: MAIN
    
    var delegate: TimingManagerDelegate! = nil
    
    //saves the state when all alarms are paused
    private var pauseState: (Date?, Bool) = (nil, false)
    
    //Corrolates to dogManager
    //Dictionary<dogName: String, Dictionary<requirementName: String, associatedTimer: Timer>>
    private var timerDictionary: Dictionary<String,Dictionary<String,Timer>>? = Dictionary<String,Dictionary<String,Timer>>()
    
    //MARK: TimingProtocol Implementation
    
    func willInitalize(dogManager: DogManager, didUnpause: Bool = false){
        
        guard pauseState.1 == false else {
            return
        }
        
        for d in 0..<dogManager.dogs.count{
            guard dogManager.dogs[d].getEnable() == true else {
                continue
            }
            
            for r in 0..<dogManager.dogs[d].dogRequirments.requirements.count{
                
                guard dogManager.dogs[d].dogRequirments.requirements[r].getEnable() == true
                else{
                    continue
                }
                
                var executionDate: Date! = nil
                
                if didUnpause == true {
                    
                    let intervalLeft: TimeInterval = dogManager.dogs[d].dogRequirments.requirements[r].interval - dogManager.dogs[d].dogRequirments.requirements[r].intervalElapsed
                    
                    executionDate = Date.executionDate(lastExecution: Date(), interval: intervalLeft)
                    
                    //debug info
                    //print("originalDate: \(pauseState.2)  pausedDate: \(pauseState.0!) currentDate: \(Date()) intervalElapsed: \(intervalElapsed.description) intervalLeft: \(intervalLeft.description) executionDate: \(executionDate.description)")
                }
                
                else if didUnpause == false{
                    executionDate = Date.executionDate(lastExecution: dogManager.dogs[d].dogRequirments.requirements[r].lastExecution, interval: dogManager.dogs[d].dogRequirments.requirements[r].interval)
                }
                
                let timer = Timer(fireAt: executionDate,
                                  interval: dogManager.dogs[d].dogRequirments.requirements[r].interval,
                                  target: self,
                                  selector: #selector(self.didExecuteTimer(sender:)),
                                  userInfo: try! ["dogName": dogManager.dogs[d].dogSpecifications.getDogSpecification(key: "name"), "requirementName": dogManager.dogs[d].dogRequirments.requirements[r].label, "dogManager": dogManager],
                                  repeats: true)
                
                RunLoop.main.add(timer, forMode: .common)
                
                var nestedtimerDictionary: Dictionary<String, Timer> = try! timerDictionary![dogManager.dogs[d].dogSpecifications.getDogSpecification(key: "name")] ?? Dictionary<String, Timer>()
                
                nestedtimerDictionary[dogManager.dogs[d].dogRequirments.requirements[r].label] = timer
                
                try! timerDictionary![dogManager.dogs[d].dogSpecifications.getDogSpecification(key: "name")] = nestedtimerDictionary
            }
        }
    }
    
    func willReinitalize(dogManager: DogManager) {
        self.invalidateAll()
        self.willInitalize(dogManager: dogManager)
    }
    
    func willReinitalize(dogName: String, requirementName: String) throws {
        //code
    }
    
    @objc private func didExecuteTimer(sender: Timer){
        guard let parsedDictionary = sender.userInfo as? [String: Any]
        else{
            ErrorProcessor.handleError(error: TimingError.parseSenderInfoFailed, sender: self)
            return
        }
        
        let dogManager: DogManager = parsedDictionary["dogManager"]! as! DogManager
        let dogName: String = parsedDictionary["dogName"]! as! String
        let requirementName: String = parsedDictionary["requirementName"]! as! String
       
        
        let title = "Alarm for \(dogName)"
        let message = try! "\(dogManager.findDog(dogName: dogName).dogRequirments.findRequirement(requirementName: requirementName).label) (\(dogManager.findDog(dogName: dogName).dogRequirments.findRequirement(requirementName: requirementName).description))"
        
        Utils.willShowAlert(title: title, message: message)
        
        let sudoDogManager = dogManager
        var sudoRequirement: Requirement = try! sudoDogManager.findDog(dogName: dogName).dogRequirments.findRequirement(requirementName: requirementName)
        sudoRequirement.changeLastExecution(newLastExecution: Date())
        sudoRequirement.changeIntervalElapsed(intervalElapsed: TimeInterval(0))
        
        delegate.didUpdateDogManager(newDogManager: sudoDogManager, sender: self)
    }
    
    private func invalidateAll() {
        for dogKey in timerDictionary!.keys{
            for requirementKey in timerDictionary![dogKey]!.keys {
                timerDictionary![dogKey]![requirementKey]!.invalidate()
            }
        }
    }
    
    func invalidate(dogName: String, requirementName: String) throws {
        if timerDictionary![dogName] == nil{
            throw TimingError.invalidateFailed
        }
        if timerDictionary![dogName]![requirementName] == nil {
            throw TimingError.invalidateFailed
        }
        timerDictionary![dogName]![requirementName]!.invalidate()
    }
    
    func willTogglePause(dogManager: DogManager, newPauseStatus: Bool) {
        if newPauseStatus == true {
            self.pauseState.0 = Date()
            self.pauseState.1 = true
            
            willPause(dogManager: dogManager)
            
            invalidateAll()
            
        }
        else {
            self.pauseState.1 = false
            willInitalize(dogManager: dogManager, didUnpause: true)
        }
    }
    
    private func willPause(dogManager: DogManager){
        let sudoDogManager = dogManager
        for dogKey in timerDictionary!.keys{
            for requirementKey in timerDictionary![dogKey]!.keys {
                var sudoRequirement = try! sudoDogManager.findDog(dogName: dogKey).dogRequirments.findRequirement(requirementName: requirementKey)
                sudoRequirement.changeIntervalElapsed(intervalElapsed: sudoRequirement.lastExecution.distance(to: pauseState.0!))
            }
        }
        
        delegate.didUpdateDogManager(newDogManager: sudoDogManager, sender: self)
    }
    
}
