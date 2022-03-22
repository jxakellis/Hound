//
//  ReminderLog.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/25/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum ReminderAction: String, CaseIterable {
    
    init?(rawValue: String) {
        // backwards compatible
        if rawValue == "Other"{
            self = .custom
            return
        }
        // regular
        for type in ReminderAction.allCases {
            if type.rawValue.lowercased() == rawValue.lowercased() {
                self = type
                return
            }
        }
        
        AppDelegate.generalLogger.fault("reminderType Not Found")
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
    
    // more common than previous but probably used less by user as weird type
    case sleep = "Sleep"
    case trainingSession = "Training Session"
    case doctor = "Doctor Visit"
    
    case custom = "Custom"
}

enum LogTypeError: Error {
    case nilLogType
    case blankLogType
}

enum LogType: String, CaseIterable {
    
    init?(rawValue: String) {
        // backwards compatible
        if rawValue == "Other"{
            self = .custom
            return
        }
        // regular
        for type in LogType.allCases {
            if type.rawValue.lowercased() == rawValue.lowercased() {
                self = type
                return
            }
        }
        
        AppDelegate.generalLogger.fault("logType Not Found")
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
    
    var logType: LogType { get set }
    
    /// If the reminder's type is custom, this is the name for it
    var customTypeName: String? { get set }
    
    /// If not .custom type then just .type name, if custom and has customTypeName then its that string
    var displayTypeName: String { get }
    
    var logId: Int { get set }
    
}

class Log: NSObject, NSCoding, NSCopying, LogProtocol {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Log(date: self.date, note: self.note, logType: self.logType, customTypeName: self.customTypeName, logId: self.logId)
        return copy
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        self.date = aDecoder.decodeObject(forKey: "date") as? Date ?? Date()
        self.note = aDecoder.decodeObject(forKey: "note") as? String ?? ""
        self.logType = LogType(rawValue: aDecoder.decodeObject(forKey: "logType") as? String ?? LogConstant.defaultType.rawValue) ?? LogConstant.defaultType
        self.customTypeName = aDecoder.decodeObject(forKey: "customTypeName") as? String
        self.logId = aDecoder.decodeInteger(forKey: "logId")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(date, forKey: "date")
        aCoder.encode(note, forKey: "note")
        aCoder.encode(logType.rawValue, forKey: "logType")
        aCoder.encode(customTypeName, forKey: "customTypeName")
        aCoder.encode(logId, forKey: "logId")
    }
    
    // static var supportsSecureCoding: Bool = true
    
    // MARK: - Main
    
    init(date: Date, note: String = "", logType: LogType, customTypeName: String? = nil, logId: Int = -1) {
        self.date = date
        self.note = note
        self.logType = logType
        self.customTypeName = customTypeName
        self.logId = logId
        super.init()
    }
    
    convenience init(fromBody body: [String: Any]) {
        
        var formattedDate: Date = Date()
        
        if let dateString = body["date"] as? String {
            formattedDate = RequestUtils.ISO8601DateFormatter.date(from: dateString) ?? Date()
        }
        
        let note: String = body["note"] as? String ?? ""
        let logType: LogType = LogType(rawValue: body["logType"] as? String ?? LogConstant.defaultType.rawValue)!
        let customTypeName: String? = body["customTypeName"] as? String
        let logId: Int = body["logId"] as? Int ?? -1
        
        self.init(date: formattedDate, note: note, logType: logType, customTypeName: customTypeName, logId: logId)
    }
    
    // MARK: Properties
    
    var date: Date
    
    var note: String
    
    var logType: LogType
    
    var customTypeName: String?
    
    var displayTypeName: String {
        if logType == .custom && customTypeName != nil {
            return customTypeName!
        }
        else {
            return logType.rawValue
        }
    }
    
    var logId: Int = -1
}
