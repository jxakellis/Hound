//
//  Timing.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 11/20/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

class Timing: TimingProtocol, DogManagerControlFlowProtocol {
    
    init(dogManager: DogManager = DogManager()){
        self.setDogManager(newDogManager: dogManager, updateDogManagerDependents: false)
        self.willInitalize()
    }
    
    //MARK: DogManagerControlFlowProtocol Implementation
    
    private var dogManager = DogManager()
    
    //Corrolates to dogManager
    //Dictionary<dogName: String, Dictionary<requirementName: String, associatedTimer: Timer>>
    private var timerManager: Dictionary<String,Dictionary<String,Timer>> = Dictionary<String,Dictionary<String,Timer>>()
    
    func getDogManager() -> DogManager {
        return dogManager.copy() as! DogManager
    }
    
    func setDogManager(newDogManager: DogManager, updateDogManagerDependents: Bool = true, sentFromSuperView: Bool = false) {
        dogManager = newDogManager.copy() as! DogManager
        
        if updateDogManagerDependents == true {
            self.updateDogManagerDependents()
        }
    }
    
    func updateDogManagerDependents() {
        willReinitalize()
    }
    
    //MARK: TimingProtocol Implementation
    
    func willInitalize() {
        print("currentDate \(Date().description)")
        for d in 0..<self.getDogManager().dogs.count{
            for r in 0..<self.getDogManager().dogs[d].dogRequirments.requirements.count{
                
                let executionDate = Date.executionDate(lastExecution: self.getDogManager().dogs[d].dogRequirments.requirements[r].lastDate, interval: self.getDogManager().dogs[d].dogRequirments.requirements[r].interval)
                
                try! print("\(self.getDogManager().dogs[d].dogSpecifications.getDogSpecification(key: "name")) + \(self.getDogManager().dogs[d].dogRequirments.requirements[r].label) + executionDate \(executionDate.description)")
                
                let timer = Timer(fireAt: executionDate,
                                  interval: self.getDogManager().dogs[d].dogRequirments.requirements[r].interval,
                                  target: self,
                                  selector: #selector(self.didExecuteTimer(sender:)),
                                  userInfo: ["dogIndex": d, "requirementIndex": r],
                                  repeats: true)
                
                RunLoop.main.add(timer, forMode: .common)
                
                var nestedTimerManager: Dictionary<String, Timer> = try! timerManager[self.getDogManager().dogs[d].dogSpecifications.getDogSpecification(key: "name")] ?? Dictionary<String, Timer>()
                
                nestedTimerManager[self.getDogManager().dogs[d].dogRequirments.requirements[r].label] = timer
                
                try! timerManager[self.getDogManager().dogs[d].dogSpecifications.getDogSpecification(key: "name")] = nestedTimerManager
                
            }
        }
    }
    
    func willReinitalize() {
        self.invalidateAll()
        self.willInitalize()
    }
    
    func willReinitalize(dogName: String, requirementName: String) throws {
        //code
    }
    
    @objc func didExecuteTimer(sender: Timer) {
        guard let parsedDictionary = sender.userInfo as? [String: Int]
        else{
            print("error timing manager didExecuteTimer")
            return
        }
        
        let dogIndex = parsedDictionary["dogIndex"]!
        let requirementIndex = parsedDictionary["requirementIndex"]!
        //let requirementIndex = sender.userInfo["requirementIndex"] as
        
        let title = try! "Alarm for \(self.getDogManager().dogs[dogIndex].dogSpecifications.getDogSpecification(key: "name"))"
        let message = "\(self.getDogManager().dogs[dogIndex].dogRequirments.requirements[requirementIndex].label) (\(self.getDogManager().dogs[dogIndex].dogRequirments.requirements[requirementIndex].description))"
        
       // keyWindow?.rootViewController?.present(alertController, animated: true, completion: nil)
        Utils.willShowAlert(title: title, message: message)
    }
    
    func willTogglePause(pasueStatus: Bool) {
        //code
    }
    
    func invalidateAll() {
        //code
    }
    
    func invalidate(dogName: String, requirementName: String) throws {
        //code
    }
    
    
}
