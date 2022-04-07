//
//  ReminderLog.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/25/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum LogAction: String, CaseIterable {
    
    init?(rawValue: String) {
        // backwards compatible
        if rawValue == "Other"{
            self = .custom
            return
        }
        // regular
        for action in LogAction.allCases {
            if action.rawValue.lowercased() == rawValue.lowercased() {
                self = action
                return
            }
        }
        
        AppDelegate.generalLogger.fault("logAction Not Found")
        self = .custom
    }
    
    case feed = "Feed"
    case water = "Fresh Water"
    
    case treat = "Treat"
    
    case pee = "Potty: Pee"
    case poo = "Potty: Poo"
    case both = "Potty: Both"
    case neither = "Potty: Didn't Go"
    case accident = "Accident"
    
    case walk = "Walk"
    case brush = "Brush"
    case bathe = "Bathe"
    case medicine = "Medicine"
    
    case wakeup = "Wake Up"
    
    case sleep = "Sleep"
    
    case crate = "Crate"
    case trainingSession = "Training Session"
    case doctor = "Doctor Visit"
    
    case custom = "Custom"
}

protocol LogProtocol {
    
    /// Date at which the log is assigned
    var logDate: Date { get set }
    
    /// Note attached to the log
    var logNote: String { get set }
    
    var logAction: LogAction { get set }
    
    /// If the reminder's action is custom, this is the name for it
    var customActionName: String? { get set }
    
    /// If not .custom action then just .action name, if custom and has customActionName then its that string
    var displayActionName: String { get }
    
    var logId: Int { get set }
    
}

class Log: NSObject, NSCoding, NSCopying, LogProtocol {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Log(logDate: self.logDate, logNote: self.logNote, logAction: self.logAction, customActionName: self.customActionName, logId: self.logId)
        return copy
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        self.logDate = aDecoder.decodeObject(forKey: "logDate") as? Date ?? Date()
        self.logNote = aDecoder.decodeObject(forKey: "logNote") as? String ?? LogConstant.defaultLogNote
        self.logAction = LogAction(rawValue: aDecoder.decodeObject(forKey: "logAction") as? String ?? LogConstant.defaultAction.rawValue) ?? LogConstant.defaultAction
        self.customActionName = aDecoder.decodeObject(forKey: "customActionName") as? String
        self.logId = aDecoder.decodeInteger(forKey: "logId")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(logDate, forKey: "logDate")
        aCoder.encode(logNote, forKey: "logNote")
        aCoder.encode(logAction.rawValue, forKey: "logAction")
        aCoder.encode(customActionName, forKey: "customActionName")
        aCoder.encode(logId, forKey: "logId")
    }
    
    // static var supportsSecureCoding: Bool = true
    
    // MARK: - Main
    
    init(logDate: Date, logNote: String = LogConstant.defaultLogNote, logAction: LogAction, customActionName: String? = nil, logId: Int = LogConstant.defaultLogId) {
        self.logDate = logDate
        self.logNote = logNote
        self.logAction = logAction
        self.customActionName = customActionName
        self.logId = logId
        super.init()
    }
    
    convenience init(fromBody body: [String: Any]) {
        
        var logDate: Date = Date()
        
        if let logDateString = body[ServerDefaultKeys.logDate.rawValue] as? String {
            logDate = ResponseUtils.dateFormatter(fromISO8601String: logDateString) ?? Date()
        }
        
        let logNote: String = body[ServerDefaultKeys.logNote.rawValue] as? String ?? LogConstant.defaultLogNote
        let logAction: LogAction = LogAction(rawValue: body[ServerDefaultKeys.logAction.rawValue] as? String ?? LogConstant.defaultAction.rawValue)!
        let customActionName: String? = body[ServerDefaultKeys.customActionName.rawValue] as? String
        let logId: Int = body[ServerDefaultKeys.logId.rawValue] as? Int ?? LogConstant.defaultLogId
        
        self.init(logDate: logDate, logNote: logNote, logAction: logAction, customActionName: customActionName, logId: logId)
    }
    
    // MARK: Properties
    
    var logDate: Date
    
    var logNote: String
    
    var logAction: LogAction
    
    var customActionName: String?
    
    var displayActionName: String {
        if logAction == .custom && customActionName != nil {
            return customActionName!
        }
        else {
            return logAction.rawValue
        }
    }
    
    var logId: Int = LogConstant.defaultLogId
}
