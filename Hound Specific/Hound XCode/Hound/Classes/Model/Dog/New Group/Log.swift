//
//  ReminderLog.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/25/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum ReminderActionError: String, Error {
    case blankReminderAction = "Your reminder has no action, try selecting one!"
}

enum ReminderAction: String, CaseIterable {
    
    init?(rawValue: String) {
        // backwards compatible
        if rawValue == "Other"{
            self = .custom
            return
        }
        // regular
        for action in ReminderAction.allCases {
            if action.rawValue.lowercased() == rawValue.lowercased() {
                self = action
                return
            }
        }
        
        AppDelegate.generalLogger.fault("reminderAction Not Found")
        self = .custom
    }
    // common
    case feed = "Feed"
    case water = "Fresh Water"
    case potty = "Potty"
    case walk = "Walk"
    // next common
    case brush = "Brush"
    case bathe = "Bathe"
    case medicine = "Medicine"
    
    // more common than previous but probably used less by user as weird action
    case sleep = "Sleep"
    case trainingSession = "Training Session"
    case doctor = "Doctor Visit"
    
    case custom = "Custom"
}

enum LogActionError: String, Error {
    case blankLogAction = "Your log has no action, try selecting one!"
}

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
    var date: Date { get set }
    
    /// Note attached to the log
    var note: String { get set }
    
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
        let copy = Log(date: self.date, note: self.note, logAction: self.logAction, customActionName: self.customActionName, logId: self.logId)
        return copy
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        self.date = aDecoder.decodeObject(forKey: "date") as? Date ?? Date()
        self.note = aDecoder.decodeObject(forKey: "note") as? String ?? LogConstant.defaultNote
        self.logAction = LogAction(rawValue: aDecoder.decodeObject(forKey: "logAction") as? String ?? LogConstant.defaultAction.rawValue) ?? LogConstant.defaultAction
        self.customActionName = aDecoder.decodeObject(forKey: "customActionName") as? String
        self.logId = aDecoder.decodeInteger(forKey: "logId")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(date, forKey: "date")
        aCoder.encode(note, forKey: "note")
        aCoder.encode(logAction.rawValue, forKey: "logAction")
        aCoder.encode(customActionName, forKey: "customActionName")
        aCoder.encode(logId, forKey: "logId")
    }
    
    // static var supportsSecureCoding: Bool = true
    
    // MARK: - Main
    
    init(date: Date, note: String = LogConstant.defaultNote, logAction: LogAction, customActionName: String? = nil, logId: Int = LogConstant.defaultLogId) {
        self.date = date
        self.note = note
        self.logAction = logAction
        self.customActionName = customActionName
        self.logId = logId
        super.init()
    }
    
    convenience init(fromBody body: [String: Any]) {
        
        var formattedDate: Date = Date()
        
        if let dateString = body["date"] as? String {
            formattedDate = RequestUtils.ISO8601DateFormatter.date(from: dateString) ?? Date()
        }
        
        let note: String = body["note"] as? String ?? LogConstant.defaultNote
        let logAction: LogAction = LogAction(rawValue: body["logAction"] as? String ?? LogConstant.defaultAction.rawValue)!
        let customActionName: String? = body["customActionName"] as? String
        let logId: Int = body["logId"] as? Int ?? LogConstant.defaultLogId
        
        self.init(date: formattedDate, note: note, logAction: logAction, customActionName: customActionName, logId: logId)
    }
    
    // MARK: Properties
    
    var date: Date
    
    var note: String
    
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
