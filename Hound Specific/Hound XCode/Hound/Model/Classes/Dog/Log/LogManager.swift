//
//  LogManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/4/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

class LogManager: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = LogManager()
        copy.storedLogs = self.storedLogs
        return copy
    }
    
    // MARK: - NSCoding
    required init?(coder aDecoder: NSCoder) {
        storedLogs = aDecoder.decodeObject(forKey: "logs") as? [Log] ?? []
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(storedLogs, forKey: "logs")
    }
    
    // MARK: - Main
    override init() {
        super.init()
    }
    
    // MARK: - Properties
    private var storedLogs: [Log] = []
    var logs: [Log] { return storedLogs }
    
    func addLog(newLog: Log) {
        
        // removes any existing logs that have the same logId as they would cause problems. .reversed() is needed to make it work, without it there will be an index of out bounds error.
        for (logIndex, log) in logs.enumerated().reversed() where log.logId == newLog.logId {
            // instead of crashing, replace the log.
            storedLogs.remove(at: logIndex)
            storedLogs.append(newLog)
            return
        }
        
        storedLogs.append(newLog)
        
    }
    
    func removeLog(forLogId logId: Int) throws {
        // check to find the index of targetted log
        var logIndex: Int?
        
        for i in 0..<logs.count where logs[i].logId == logId {
            logIndex = i
            break
        }
        
        if logIndex == nil {
            throw LogManagerError.logIdNotPresent
        }
        else {
            storedLogs.remove(at: logIndex ?? LogConstant.defaultLogId)
        }
    }
    
    func removeLog(forIndex index: Int) {
        storedLogs.remove(at: index)
    }
    
    /// Returns an array of known log actions. Each known log action has an array of logs attached to it. This means you can find every log for a given log action
    var catagorizedLogActions: [(LogAction, [Log])] {
        var catagorizedLogActions: [(LogAction, [Log])] = []
        
        // handles all dog logs and adds to catagorized log actions
        for dogLog in logs {
            // already contains that dog log action, needs to append
            if catagorizedLogActions.contains(where: { (arg1) -> Bool in
                let logAction = arg1.0
                if dogLog.logAction == logAction {
                    return true
                }
                else {
                    return false
                }
            }) == true {
                // since logAction is already present, append on dogLog that is of that same action to the arry of logs with the given logAction
                let targetIndex: Int! = catagorizedLogActions.firstIndex(where: { (arg1) -> Bool in
                    let logAction = arg1.0
                    if logAction == dogLog.logAction {
                        return true
                    }
                    else {
                        return false
                    }
                })
                
                catagorizedLogActions[targetIndex].1.append(dogLog)
            }
            // does not contain that dog Log's Action
            else {
                catagorizedLogActions.append((dogLog.logAction, [dogLog]))
            }
        }
        
        // sorts by the order defined by the enum, so whatever case is first in the code of the enum that is the order of the catagorizedLogActions
        catagorizedLogActions.sort { arg1, arg2 in
            let (logAction1, _) = arg1
            let (logAction2, _) = arg2
            
            // finds corrosponding index
            let logAction1Index: Int! = LogAction.allCases.firstIndex { arg1 in
                if logAction1.rawValue == arg1.rawValue {
                    return true
                }
                else {
                    return false
                }
            }
            // finds corrosponding index
            let logAction2Index: Int! = LogAction.allCases.firstIndex { arg1 in
                if logAction2.rawValue == arg1.rawValue {
                    return true
                }
                else {
                    return false
                }
            }
            
            if logAction1Index <= logAction2Index {
                return true
            }
            else {
                return false
            }
            
        }
        
        return catagorizedLogActions
    }
    
}
