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

class TimingManager: TimingProtocol, DogManagerControlFlowProtocol {
    
    var delegate: TimingManagerDelegate! = nil
    
    //saves the state when all alarms are paused
    private var pauseState: (Date?, Bool, Date) = (nil, false, Date())
    
    //MARK: DogManagerControlFlowProtocol Implementation
    
    private var dogManager = DogManager()
    
    //Corrolates to dogManager
    //Dictionary<dogName: String, Dictionary<requirementName: String, associatedTimer: Timer>>
    private var timerManager: Dictionary<String,Dictionary<String,Timer>> = Dictionary<String,Dictionary<String,Timer>>()
    
    func getDogManager() -> DogManager {
        return dogManager.copy() as! DogManager
    }
    
    func setDogManager(newDogManager: DogManager, sender: AnyObject?) {
        
        dogManager = newDogManager.copy() as! DogManager
        
        if !(sender is TimingManager) {
            self.updateDogManagerDependents()
        }
        else if sender is TimingManager {
            delegate.didUpdateDogManager(newDogManager: getDogManager(), sender: self)
        }
        
    }
    
    func updateDogManagerDependents() {
        willReinitalize()
    }
    
    //MARK: TimingProtocol Implementation
    
    private func willInitalize(didUnpause: Bool = false) {
        guard pauseState.1 == false else {
            return
        }
        for d in 0..<self.getDogManager().dogs.count{
            guard self.getDogManager().dogs[d].getEnable() == true else {
                continue
            }
            
            for r in 0..<self.getDogManager().dogs[d].dogRequirments.requirements.count{
                
                guard self.getDogManager().dogs[d].dogRequirments.requirements[r].getEnable() == true
                else{
                    continue
                }
                
                var executionDate: Date! = nil
                
                if didUnpause == true {
                    let intervalElapsed: TimeInterval = self.getDogManager().dogs[d].dogRequirments.requirements[r].lastExecution.distance(to: pauseState.0!)
                    
                    let intervalLeft: TimeInterval = getDogManager().dogs[d].dogRequirments.requirements[r].interval - intervalElapsed
                    
                    executionDate = Date.executionDate(lastExecution: Date(), interval: intervalLeft)
                    
                    //debug info
                    //print("originalDate: \(pauseState.2)  pausedDate: \(pauseState.0!) currentDate: \(Date()) intervalElapsed: \(intervalElapsed.description) intervalLeft: \(intervalLeft.description) executionDate: \(executionDate.description)")
                }
                
                else if didUnpause == false{
                    executionDate = Date.executionDate(lastExecution: self.getDogManager().dogs[d].dogRequirments.requirements[r].lastExecution, interval: self.getDogManager().dogs[d].dogRequirments.requirements[r].interval)
                }
                
                let timer = Timer(fireAt: executionDate,
                                  interval: self.getDogManager().dogs[d].dogRequirments.requirements[r].interval,
                                  target: self,
                                  selector: #selector(self.didExecuteTimer(sender:)),
                                  userInfo: try! ["dogName": self.getDogManager().dogs[d].dogSpecifications.getDogSpecification(key: "name"), "requirementName": self.getDogManager().dogs[d].dogRequirments.requirements[r].label],
                                  repeats: true)
                
                RunLoop.main.add(timer, forMode: .common)
                
                var nestedTimerManager: Dictionary<String, Timer> = try! timerManager[self.getDogManager().dogs[d].dogSpecifications.getDogSpecification(key: "name")] ?? Dictionary<String, Timer>()
                
                nestedTimerManager[self.getDogManager().dogs[d].dogRequirments.requirements[r].label] = timer
                
                try! timerManager[self.getDogManager().dogs[d].dogSpecifications.getDogSpecification(key: "name")] = nestedTimerManager
                
            }
        }
    }
    
    private func willReinitalize() {
        self.invalidateAll()
        self.willInitalize()
    }
    
    func willReinitalize(dogName: String, requirementName: String) throws {
        //code
    }
    
    @objc private func didExecuteTimer(sender: Timer) {
        guard let parsedDictionary = sender.userInfo as? [String: String]
        else{
            print("error timing manager didExecuteTimer")
            return
        }
        
        let dogName = parsedDictionary["dogName"]!
        let requirementName = parsedDictionary["requirementName"]!
        
        let title = "Alarm for \(dogName)"
        let message = try! "\(self.getDogManager().findDog(dogName: dogName).dogRequirments.findRequirement(requirementName: requirementName).label) (\(self.getDogManager().findDog(dogName: dogName).dogRequirments.findRequirement(requirementName: requirementName).description))"
        
        Utils.willShowAlert(title: title, message: message)
        
        let sudoDogManager = getDogManager()
        var sudoRequirement: Requirement = try! sudoDogManager.findDog(dogName: dogName).dogRequirments.findRequirement(requirementName: requirementName)
        sudoRequirement.changeLastExecution(newLastExecution: Date())
        
        setDogManager(newDogManager: sudoDogManager, sender: self)
    }
    
    private func invalidateAll() {
        for dogKey in timerManager.keys{
            for requirementKey in timerManager[dogKey]!.keys {
                timerManager[dogKey]![requirementKey]!.invalidate()
            }
        }
    }
    
    func invalidate(dogName: String, requirementName: String) throws {
        if timerManager[dogName] == nil{
            throw TimingError.unableToInvalidate
        }
        if timerManager[dogName]![requirementName] == nil {
            throw TimingError.unableToInvalidate
        }
        timerManager[dogName]![requirementName]!.invalidate()
    }
    
    func willTogglePause(newPauseStatus: Bool) {
        if newPauseStatus == true {
            invalidateAll()
            self.pauseState.0 = Date()
            self.pauseState.1 = true
        }
        else {
            self.pauseState.1 = false
            willInitalize(didUnpause: true)
        }
    }
    
}
