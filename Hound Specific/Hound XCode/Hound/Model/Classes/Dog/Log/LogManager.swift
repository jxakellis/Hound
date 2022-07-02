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
        copy.storedCatagorizedLogActions = self.storedCatagorizedLogActions
        return copy
    }
    
    // MARK: - NSCoding
    required init?(coder aDecoder: NSCoder) {
        storedLogs = aDecoder.decodeObject(forKey: "logs") as? [Log] ?? []
        storedCatagorizedLogActions = aDecoder.decodeObject(forKey: "catagorizedLogActions") as? [(LogAction, [Log])] ?? nil
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(storedLogs, forKey: "logs")
        aCoder.encode(storedCatagorizedLogActions, forKey: "catagorizedLogActions")
    }
    
    // MARK: - Main
    override init() {
        super.init()
    }
    
    convenience init(fromBody logBodies: [[String: Any]]) {
        self.init()
        
        for logBody in logBodies {
            let log = Log(fromBody: logBody)
            addLog(newLog: log)
        }
        
    }
    
    // MARK: - Properties
    private var storedLogs: [Log] = []
    var logs: [Log] { return storedLogs }
    
    // Stores the result of catagorizedLogActions. This increases efficency as if catagorizedLogActions is called multiple times, without the logs array changing, we return this same stored value. If the logs array is updated, then we invalidate the stored value so its recalculated next time
    private var storedCatagorizedLogActions: [(LogAction, [Log])]?
    
    /// Helper function allows us to use the same logic for addLog and addLogs and allows us to only sort at the end. Without this function, addLogs would invoke addLog repeadly and sortLogs() with each call.
    private func addLogWithoutSorting(newLog: Log) {
        // removes any existing logs that have the same logId as they would cause problems. .reversed() is needed to make it work, without it there will be an index of out bounds error.
        for (logIndex, log) in logs.enumerated().reversed() where log.logId == newLog.logId {
            // replace the log
            storedLogs.remove(at: logIndex)
            break
        }
        
        storedCatagorizedLogActions = nil
        storedLogs.append(newLog)
    }
    
    func addLog(newLog: Log) {
        
        addLogWithoutSorting(newLog: newLog)
        
        sortLogs()
        
    }
    
    func addLogs(newLogs: [Log]) {
        
        for newLog in newLogs {
            addLogWithoutSorting(newLog: newLog)
        }
        
        sortLogs()
        
    }
    
    /// No sort currently used
    private func sortLogs() {
        // no sort currently used
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
            storedCatagorizedLogActions = nil
            storedLogs.remove(at: logIndex ?? LogConstant.defaultLogId)
        }
    }
    
    func removeLog(forIndex index: Int) {
        storedCatagorizedLogActions = nil
        storedLogs.remove(at: index)
    }
    
    // MARK: Information
    
    /// Returns an array of known log actions. Each known log action has an array of logs attached to it. This means you can find every log for a given log action
    var catagorizedLogActions: [(LogAction, [Log])] {
        // If we have the output of this calculated property stored, return it. Increases efficency by not doing calculation multiple times. Stored property is set to nil if any logs change, so in that case we would recalculate
        guard storedCatagorizedLogActions == nil else {
            return storedCatagorizedLogActions!
        }
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
        
        storedCatagorizedLogActions = catagorizedLogActions
        return catagorizedLogActions
    }
    
}

extension LogManager {
    
    // MARK: Compare
    
    /// Combines the logs of an old log manager with the new log manager, forming a union with their log arrays. In the event that the newLogManager (this object) has a log with the same id as the oldLogManager, the log from the newLogManager will override that log
    func combine(withOldLogManager oldLogManager: LogManager) {
        // the addLogs function overwrites logs if it finds them, so we must add the logs to the old log (allowing the newLogManager to overwrite the oldLogManager logs if there is an overlap)
        oldLogManager.addLogs(newLogs: self.logs)
        // now that the oldLogManager contains its original logs, our new logs, and has had its old logs overwritten (in the case old & new both had a log with same logId), we have an updated array.
        storedCatagorizedLogActions = nil
        self.storedLogs = oldLogManager.logs
    }
}
