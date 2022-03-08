//
//  LogManager.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/4/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

/// Enum full of cases of possible errors
enum LogManagerError: Error {
    case logIdPresent
    case logIdNotPresent
}

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
            AppDelegate.endpointLogger.notice("ENDPOINT Update Log")
            return
        }

        storedLogs.append(newLog)
        AppDelegate.endpointLogger.notice("ENDPOINT Add Log")

    }

    /*
     func changeLog(forLogId logId: String, newLog: Log) throws {
         //check to find the index of targetted log
         var newLogIndex: Int?
         
         for i in 0..<logs.count {
             if logs[i].logId == logId {
                 newLogIndex = i
                 break
             }
         }
         
         if newLogIndex == nil {
             throw TraitManagerError.logIdNotPresent
         }
         
         else {
             storedLogs[newLogIndex!] = newLog
             AppDelegate.endpointLogger.notice("ENDPOINT Update Log")
         }
     }
     */

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
            storedLogs.remove(at: logIndex ?? -1)
            AppDelegate.endpointLogger.notice("ENDPOINT Remove Log (logId)")
        }
    }

    func removeLog(forIndex index: Int) {
        storedLogs.remove(at: index)
        AppDelegate.endpointLogger.notice("ENDPOINT Remove Log (index)")
    }

    /// Returns an array of known log types. Each known log type has an array of logs attached to it. This means you can find every log for a given log type
    var catagorizedLogTypes: [(LogType, [Log])] {
        var catagorizedLogTypes: [(LogType, [Log])] = []

        // handles all dog logs and adds to catagorized log types
        for dogLog in logs {
            // already contains that dog log type, needs to append
            if catagorizedLogTypes.contains(where: { (arg1) -> Bool in
                let logType = arg1.0
                if dogLog.logType == logType {
                    return true
                }
                else {
                    return false
                }
            }) == true {
                // since logType is already present, append on dogLog that is of that same type to the arry of logs with the given logType
                let targetIndex: Int! = catagorizedLogTypes.firstIndex(where: { (arg1) -> Bool in
                    let logType = arg1.0
                    if logType == dogLog.logType {
                        return true
                    }
                    else {
                        return false
                    }
                })

                catagorizedLogTypes[targetIndex].1.append(dogLog)
            }
            // does not contain that dog Log's Type
            else {
                catagorizedLogTypes.append((dogLog.logType, [dogLog]))
            }
        }

        // sorts by the order defined by the enum, so whatever case is first in the code of the enum that is the order of the catagorizedLogTypes
        catagorizedLogTypes.sort { arg1, arg2 in
            let (logType1, _) = arg1
            let (logType2, _) = arg2

            // finds corrosponding index
            let logType1Index: Int! = LogType.allCases.firstIndex { arg1 in
                if logType1.rawValue == arg1.rawValue {
                    return true
                }
                else {
                    return false
                }
            }
            // finds corrosponding index
            let logType2Index: Int! = LogType.allCases.firstIndex { arg1 in
                if logType2.rawValue == arg1.rawValue {
                    return true
                }
                else {
                    return false
                }
            }

            if logType1Index <= logType2Index {
                return true
            }
            else {
                return false
            }

        }

        return catagorizedLogTypes
    }

}
