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
    
    /// Returns the name of the current logAction with an appropiate emoji appended. If non-nil, non-"" logCustomActionName is provided, then then that is returned, e.g. displayActionName(nil) -> 'Feed 🍗'; displayActionName(nil) -> 'Custom 📝'; displayActionName('someCustomName', true) -> 'someCustomName'; displayActionName('someCustomName', false) -> 'Custom 📝: someCustomName'
    func displayActionName(logCustomActionName: String?, isShowingAbreviatedCustomActionName: Bool) -> String {
        switch self {
        case .feed:
            return self.rawValue.appending(" 🍗")
        case .water:
            return self.rawValue.appending(" 💧")
        case .treat:
            return self.rawValue.appending(" 🦴")
        case .pee:
            return self.rawValue.appending(" 💦")
        case .poo:
            return self.rawValue.appending(" 💩")
        case .both:
            return self.rawValue.appending(" 💦💩")
        case .neither:
            return self.rawValue
        case .accident:
            return self.rawValue.appending(" ⚠️")
        case .walk:
            return self.rawValue.appending(" 🦮")
        case .brush:
            return self.rawValue.appending(" 💈")
        case .bathe:
            return self.rawValue.appending(" 🛁")
        case .medicine:
            return self.rawValue.appending(" 💊")
        case .wakeup:
            return self.rawValue.appending(" ☀️")
        case .sleep:
            return self.rawValue.appending(" 💤")
        case .crate:
            return self.rawValue.appending(" 🏡")
        case .trainingSession:
            return self.rawValue.appending(" 🐾")
        case .doctor:
            return self.rawValue.appending(" 🩺")
        case .custom:
            if logCustomActionName != nil && logCustomActionName!.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                if isShowingAbreviatedCustomActionName == true {
                    return logCustomActionName!
                }
                else {
                    return self.rawValue.appending(" 📝: \(logCustomActionName!)")
                }
            }
            else {
                return self.rawValue.appending(" 📝")
            }
        }
    }
}

protocol LogProtocol {
    
    /// Date at which the log is assigned
    var logDate: Date { get set }
    
    /// Note attached to the log
    var logNote: String { get set }
    
    var logAction: LogAction { get set }
    
    /// If the reminder's action is custom, this is the name for it
    var logCustomActionName: String? { get set }
    
    var logId: Int { get set }
    
}

class Log: NSObject, NSCoding, NSCopying, LogProtocol {
    
    // TO DO implement userId of person who created the log. then, with this user id, display it on the logs page or wherever else needed (i.e. show that x person created the log)
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Log(logDate: self.logDate, logNote: self.logNote, logAction: self.logAction, logCustomActionName: self.logCustomActionName, logId: self.logId)
        return copy
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        self.logDate = aDecoder.decodeObject(forKey: "logDate") as? Date ?? Date()
        self.logNote = aDecoder.decodeObject(forKey: "logNote") as? String ?? LogConstant.defaultLogNote
        self.logAction = LogAction(rawValue: aDecoder.decodeObject(forKey: "logAction") as? String ?? LogConstant.defaultAction.rawValue) ?? LogConstant.defaultAction
        self.logCustomActionName = aDecoder.decodeObject(forKey: "logCustomActionName") as? String
        self.logId = aDecoder.decodeInteger(forKey: "logId")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(logDate, forKey: "logDate")
        aCoder.encode(logNote, forKey: "logNote")
        aCoder.encode(logAction.rawValue, forKey: "logAction")
        aCoder.encode(logCustomActionName, forKey: "logCustomActionName")
        aCoder.encode(logId, forKey: "logId")
    }
    
    // static var supportsSecureCoding: Bool = true
    
    // MARK: - Main
    
    init(logDate: Date, logNote: String = LogConstant.defaultLogNote, logAction: LogAction, logCustomActionName: String? = nil, logId: Int = LogConstant.defaultLogId) {
        self.logDate = logDate
        self.logNote = logNote
        self.logAction = logAction
        self.logCustomActionName = logCustomActionName
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
        let logCustomActionName: String? = body[ServerDefaultKeys.logCustomActionName.rawValue] as? String
        let logId: Int = body[ServerDefaultKeys.logId.rawValue] as? Int ?? LogConstant.defaultLogId
        
        self.init(logDate: logDate, logNote: logNote, logAction: logAction, logCustomActionName: logCustomActionName, logId: logId)
    }
    
    // MARK: Properties
    
    var logDate: Date
    
    var logNote: String
    
    var logAction: LogAction
    
    var logCustomActionName: String?
    
    var logId: Int = LogConstant.defaultLogId
}
