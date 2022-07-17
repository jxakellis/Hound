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
        // regular
        for action in LogAction.allCases {
            if action.rawValue.lowercased() == rawValue.lowercased() {
                self = action
                return
            }
        }
        
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

final class Log: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = Log(logId: self.logId, logAction: self.logAction, logCustomActionName: self.logCustomActionName, logDate: self.logDate, logNote: self.logNote)
        return copy
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        self.logId = aDecoder.decodeInteger(forKey: "logId")
        self.userId = aDecoder.decodeObject(forKey: "userId") as? String ?? ClassConstant.LogConstant.defaultUserId
        self.logAction = LogAction(rawValue: aDecoder.decodeObject(forKey: "logAction") as? String ?? ClassConstant.LogConstant.defaultLogAction.rawValue) ?? ClassConstant.LogConstant.defaultLogAction
        self.logCustomActionName = aDecoder.decodeObject(forKey: "logCustomActionName") as? String
        self.logDate = aDecoder.decodeObject(forKey: "logDate") as? Date ?? Date()
        self.logNote = aDecoder.decodeObject(forKey: "logNote") as? String ?? ClassConstant.LogConstant.defaultLogNote
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(logId, forKey: "logId")
        aCoder.encode(userId, forKey: "userId")
        aCoder.encode(logAction.rawValue, forKey: "logAction")
        aCoder.encode(logCustomActionName, forKey: "logCustomActionName")
        aCoder.encode(logDate, forKey: "logDate")
        aCoder.encode(logNote, forKey: "logNote")
    }
    
    // MARK: - Main
    
    override init() {
        super.init()
    }
    
    convenience init(
        logId: Int = ClassConstant.LogConstant.defaultLogId,
        userId: String = ClassConstant.LogConstant.defaultUserId,
        logAction: LogAction = ClassConstant.LogConstant.defaultLogAction,
        logCustomActionName: String? = ClassConstant.LogConstant.defaultLogCustomActionName,
        logDate: Date = ClassConstant.LogConstant.defaultLogDate,
        logNote: String = ClassConstant.LogConstant.defaultLogNote
    ) {
        self.init()
        
        self.logId = logId
        self.userId = userId
        self.logAction = logAction
        self.logCustomActionName = logCustomActionName
        self.logDate = logDate
        self.logNote = logNote
    }
    
    convenience init(fromBody body: [String: Any]) {
        
        let logId: Int = body[ServerDefaultKeys.logId.rawValue] as? Int ?? ClassConstant.LogConstant.defaultLogId
        // don't user ClassConstant.LogConstant.defaultUserId here. if we cannot decode the value, then just leave it as -1, as otherwise it would incorrectly display that this user created the log (as ClassConstant.LogConstant.defaultUserId defaults to UserInformation.userId first)
        let userId: String = body[ServerDefaultKeys.userId.rawValue] as? String ?? EnumConstant.HashConstant.defaultSHA256Hash
        let logAction: LogAction = LogAction(rawValue: body[ServerDefaultKeys.logAction.rawValue] as? String ?? ClassConstant.LogConstant.defaultLogAction.rawValue)!
        let logCustomActionName: String? = body[ServerDefaultKeys.logCustomActionName.rawValue] as? String ?? ClassConstant.LogConstant.defaultLogCustomActionName
        
        var logDate: Date = ClassConstant.LogConstant.defaultLogDate
        if let logDateString = body[ServerDefaultKeys.logDate.rawValue] as? String {
            logDate = ResponseUtils.dateFormatter(fromISO8601String: logDateString) ?? ClassConstant.LogConstant.defaultLogDate
        }
        
        let logNote: String = body[ServerDefaultKeys.logNote.rawValue] as? String ?? ClassConstant.LogConstant.defaultLogNote
        
        self.init(logId: logId, userId: userId, logAction: logAction, logCustomActionName: logCustomActionName, logDate: logDate, logNote: logNote)
        
        logIsDeleted = body[ServerDefaultKeys.logIsDeleted.rawValue] as? Bool ?? false
    }
    
    // MARK: Properties
    
    var logId: Int = ClassConstant.LogConstant.defaultLogId
    
    var userId: String = ClassConstant.LogConstant.defaultUserId
    
    /// This property a marker leftover from when we went through the process of constructing a new log from JSON and combining with an existing log object. This markers allows us to have a new log to overwrite the old log, then leaves an indicator that this should be deleted. This deletion is handled by DogsRequest
    private(set) var logIsDeleted: Bool = false
    
    var logAction: LogAction = ClassConstant.LogConstant.defaultLogAction
    
    private(set) var logCustomActionName: String? = ClassConstant.LogConstant.defaultLogCustomActionName
    func changeLogCustomActionName(forLogCustomActionName: String?) throws {
        guard forLogCustomActionName?.count ?? 0 <= ClassConstant.LogConstant.logCustomActionNameCharacterLimit else {
            throw LogError.logCustomActionNameCharacterLimitExceeded
        }
        
        logCustomActionName = forLogCustomActionName
    }
    
    var logDate: Date = ClassConstant.LogConstant.defaultLogDate
    
    var logNote: String = ClassConstant.LogConstant.defaultLogNote
    
}

extension Log {
    // MARK: - Request
    
    /// Returns an array literal of the logs's properties. This is suitable to be used as the JSON body for a HTTP request
    func createBody() -> [String: Any] {
        var body: [String: Any] = [:]
        body[ServerDefaultKeys.logNote.rawValue] = logNote
        body[ServerDefaultKeys.logDate.rawValue] = logDate.ISO8601FormatWithFractionalSeconds()
        body[ServerDefaultKeys.logAction.rawValue] = logAction.rawValue
        body[ServerDefaultKeys.logCustomActionName.rawValue] = logCustomActionName
        return body
        
    }
}
