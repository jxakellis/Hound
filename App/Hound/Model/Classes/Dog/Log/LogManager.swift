//
//  LogManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/4/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class LogManager: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
       func copy(with zone: NSZone? = nil) -> Any {
           let copy = LogManager()
           for log in logs {
               if let logCopy = log.copy() as? Log {
                   copy.logs.append(logCopy)
               }
           }
           if let uniqueLogActionsResult = uniqueLogActionsResult {
               copy.uniqueLogActionsResult = []
               for uniqueLogActionCopy in uniqueLogActionsResult {
                   copy.uniqueLogActionsResult?.append(uniqueLogActionCopy)
               }
           }
           return copy
       }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        logs = aDecoder.decodeObject(forKey: KeyConstant.logs.rawValue) as? [Log] ?? logs
        
        // <= build 3810 dogName stored here
        dataMigrationDogName = aDecoder.decodeObject(forKey: "dogName") as? String
        
        // <= build 3810 icon stored here
        dataMigrationDogIcon = aDecoder.decodeObject(forKey: "icon") as? UIImage
        
        // If multiple logs have the same placeholder id (e.g. migrating from Hound 1.3.5 to 2.0.0), shift the dogIds so they all have a unique placeholder id
        var lowestPlaceholderId: Int = Int.max
        for log in logs where log.logId <= -1 && log.logId >= lowestPlaceholderId {
            // the currently iterated over log has a placeholder id that overlaps with another placeholder id
            log.logId = lowestPlaceholderId - 1
            lowestPlaceholderId = log.logId
        }
        
        print("finished decoding LogManager")
        for log in logs {
            print("logId \(log.logId)")
        }
        print("dogName \(dataMigrationDogName)")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(logs, forKey: KeyConstant.logs.rawValue)
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
    
    // <= build 3810 dogName was stored in TraitManager. TraitManager became LogManager when migrating to new system dogName is contained in here
    var dataMigrationDogName: String?
    
    // <= build 3810 dogIcon was stored in TraitManager. TraitManager became LogManager when migrating to new system dogIcon is contained in here
    var dataMigrationDogIcon: UIImage?
    
    // Stores the result of uniqueLogActions. This increases efficency as if uniqueLogActions is called multiple times, without the logs array changing, we return this same stored value. If the logs array is updated, then we invalidate the stored value so its recalculated next time
    private var uniqueLogActionsResult: [LogAction]?
    
    // MARK: - Functions
    
    /// Helper function allows us to use the same logic for addLog and addLogs and allows us to only sort at the end. Without this function, addLogs would invoke addLog repeadly and sortLogs() with each call.
    private func addLogWithoutSorting(forLog newLog: Log) {
        // removes any existing logs that have the same logId as they would cause problems.
        logs.removeAll { oldLog in
            return newLog.logId == oldLog.logId
        }
        
        logs.append(newLog)
        
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
    
    func removeLog(forLogId logId: Int) {
        // check to find the index of targetted log
        let logIndex: Int? = logs.firstIndex { log in
            return log.logId == logId
        }
        
        guard let logIndex = logIndex else {
            return
        }
        
        logs.remove(at: logIndex)
        uniqueLogActionsResult = nil
    }
    
    func removeLog(forIndex index: Int) {
        // Make sure the index is valid
        guard logs.count > index else {
            return
        }
        
        logs.remove(at: index)
        uniqueLogActionsResult = nil
    }
    
    // MARK: Information
    
    /// Returns an array of known log actions. Each known log action has an array of logs attached to it. This means you can find every log for a given log action
    var uniqueLogActions: [LogAction] {
        // If we have the output of this calculated property stored, return it. Increases efficency by not doing calculation multiple times. Stored property is set to nil if any logs change, so in that case we would recalculate
        if let uniqueLogActionsResult = uniqueLogActionsResult {
            return uniqueLogActionsResult
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
        // we need to copy oldLogManager as it might still be in use and the combining process modifies oldLogManager. Therefore, copy is necessary to keep oldLogManager integrity.
        guard let oldLogManagerCopy = oldLogManager.copy() as? LogManager else {
            return
        }
        
        // the addLogs function overwrites logs if it finds them, so we must add the logs to the old log (allowing the newLogManager to overwrite the oldLogManager logs if there is an overlap)
        oldLogManagerCopy.addLogs(forLogs: self.logs)
        // now that the oldLogManager contains its original logs, our new logs, and has had its old logs overwritten (in the case old & new both had a log with same logId), we have an updated array.
        logs = oldLogManagerCopy.logs
        uniqueLogActionsResult = nil
    }
}
