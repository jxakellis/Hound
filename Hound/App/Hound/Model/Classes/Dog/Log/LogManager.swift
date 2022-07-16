//
//  LogManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/4/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

final class LogManager: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = LogManager()
        copy.logs = logs
        copy.uniqueLogActionsResult = uniqueLogActionsResult
        return copy
    }
    
    // MARK: - NSCoding
    required init?(coder aDecoder: NSCoder) {
        logs = aDecoder.decodeObject(forKey: "logs") as? [Log] ?? []
        uniqueLogActionsResult = aDecoder.decodeObject(forKey: "uniqueLogActions") as? [LogAction] ?? nil
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(logs, forKey: "logs")
        aCoder.encode(uniqueLogActionsResult, forKey: "uniqueLogActions")
    }
    
    // MARK: - Main
    override init() {
        super.init()
    }
    
    convenience init(fromBody logBodies: [[String: Any]]) {
        self.init()
        
        for logBody in logBodies {
            let log = Log(fromBody: logBody)
            addLog(forLog: log)
        }
        
    }
    
    // MARK: - Properties
    private (set) var logs: [Log] = []
    
    // Stores the result of uniqueLogActions. This increases efficency as if uniqueLogActions is called multiple times, without the logs array changing, we return this same stored value. If the logs array is updated, then we invalidate the stored value so its recalculated next time
    private var uniqueLogActionsResult: [LogAction]?
    
    /// Helper function allows us to use the same logic for addLog and addLogs and allows us to only sort at the end. Without this function, addLogs would invoke addLog repeadly and sortLogs() with each call.
    private func addLogWithoutSorting(forLog: Log) {
        // removes any existing logs that have the same logId as they would cause problems. .reversed() is needed to make it work, without it there will be an index of out bounds error.
        for (logIndex, log) in logs.enumerated().reversed() where log.logId == forLog.logId {
            // replace the log
            logs.remove(at: logIndex)
            break
        }
        logs.append(forLog)
        
        uniqueLogActionsResult = nil
    }
    
    func addLog(forLog log: Log) {
        
        addLogWithoutSorting(forLog: log)
        
        sortLogs()
        
    }
    
    func addLogs(forLogs logs: [Log]) {
        
        for log in logs {
            addLogWithoutSorting(forLog: log)
        }
        
        sortLogs()
        
    }
    
    private func sortLogs() {
        logs.sort { (log1, log2) -> Bool in
            // Returning true means item1 comes before item2, false means item2 before item1
            
            // Returns true if var1's log1 is earlier in time than var2's log2
            
            // If date1's distance to date2 is positive, i.e. date2 is later in time, returns false as date2 should be ordered first (most recent (to current Date()) dates first)
            // If date1 is later in time than date2, returns true as it should come before date2
            return log1.logDate.distance(to: log2.logDate) <= 0
        }
    }
    
    func removeLog(forLogId logId: Int) throws {
        // check to find the index of targetted log
        let logIndex: Int? = logs.firstIndex { log in
            return log.logId == logId
        }
        
        if logIndex == nil {
            throw LogManagerError.logIdNotPresent
        }
        else {
            logs.remove(at: logIndex ?? ClassConstant.LogConstant.defaultLogId)
            uniqueLogActionsResult = nil
        }
    }
    
    func removeLog(forIndex index: Int) {
        logs.remove(at: index)
        uniqueLogActionsResult = nil
    }
    
    // MARK: Information
    
    /// Returns an array of known log actions. Each known log action has an array of logs attached to it. This means you can find every log for a given log action
    var uniqueLogActions: [LogAction] {
        // If we have the output of this calculated property stored, return it. Increases efficency by not doing calculation multiple times. Stored property is set to nil if any logs change, so in that case we would recalculate
        guard uniqueLogActionsResult == nil else {
            return uniqueLogActionsResult!
        }
        
        var logActions: [LogAction] = []
        
        // find all unique logActions
        for dogLog in logs where logActions.contains(dogLog.logAction) == false {
            // If we have added all of the logActions possible, then stop the loop as there is no point for more iteration
            guard logActions.count != LogAction.allCases.count else {
                break
            }
            logActions.append(dogLog.logAction)
        }
        
        // sorts by the order defined by the enum, so whatever case is first in the code of the enum that is the order of the uniqueLogActions
        logActions.sort { logAction1, logAction2 in
            
            // finds corrosponding indexs
            let logAction1Index: Int! = LogAction.allCases.firstIndex(of: logAction1)
            let logAction2Index: Int! = LogAction.allCases.firstIndex(of: logAction2)
            
            return logAction1Index <= logAction2Index
        }
        
        uniqueLogActionsResult = logActions
        return logActions
    }
    
}

extension LogManager {
    
    // MARK: Compare
    
    /// Combines the logs of an old log manager with the new log manager, forming a union with their log arrays. In the event that the newLogManager (this object) has a log with the same id as the oldLogManager, the log from the newLogManager will override that log
    func combine(withOldLogManager oldLogManager: LogManager) {
        // the addLogs function overwrites logs if it finds them, so we must add the logs to the old log (allowing the newLogManager to overwrite the oldLogManager logs if there is an overlap)
        oldLogManager.addLogs(forLogs: self.logs)
        // now that the oldLogManager contains its original logs, our new logs, and has had its old logs overwritten (in the case old & new both had a log with same logId), we have an updated array.
        logs = oldLogManager.logs
        uniqueLogActionsResult = nil
        sortLogs()
    }
}
