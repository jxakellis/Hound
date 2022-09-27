//
//  ReminderLog.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/25/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class Log: NSObject, NSCoding {
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        logId = aDecoder.decodeInteger(forKey: KeyConstant.logId.rawValue)
        userId = aDecoder.decodeObject(forKey: KeyConstant.userId.rawValue) as? String ?? userId
        logAction = LogAction(rawValue: aDecoder.decodeObject(forKey: KeyConstant.logAction.rawValue) as? String ?? ClassConstant.LogConstant.defaultLogAction.rawValue) ?? logAction
        logCustomActionName = aDecoder.decodeObject(forKey: KeyConstant.logCustomActionName.rawValue) as? String ?? logCustomActionName
        logDate = aDecoder.decodeObject(forKey: KeyConstant.logDate.rawValue) as? Date ?? logDate
        logNote = aDecoder.decodeObject(forKey: KeyConstant.logNote.rawValue) as? String ?? logNote
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(logId, forKey: KeyConstant.logId.rawValue)
        aCoder.encode(userId, forKey: KeyConstant.userId.rawValue)
        aCoder.encode(logAction.rawValue, forKey: KeyConstant.logAction.rawValue)
        aCoder.encode(logCustomActionName, forKey: KeyConstant.logCustomActionName.rawValue)
        aCoder.encode(logDate, forKey: KeyConstant.logDate.rawValue)
        aCoder.encode(logNote, forKey: KeyConstant.logNote.rawValue)
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
        
        let logId: Int = body[KeyConstant.logId.rawValue] as? Int ?? ClassConstant.LogConstant.defaultLogId
        // don't user ClassConstant.LogConstant.defaultUserId here. if we cannot decode the value, then just leave it as -1, as otherwise it would incorrectly display that this user created the log (as ClassConstant.LogConstant.defaultUserId defaults to UserInformation.userId first)
        let userId: String = body[KeyConstant.userId.rawValue] as? String ?? Hash.defaultSHA256Hash
        let logAction: LogAction = LogAction(rawValue: body[KeyConstant.logAction.rawValue] as? String ?? ClassConstant.LogConstant.defaultLogAction.rawValue) ?? ClassConstant.LogConstant.defaultLogAction
        let logCustomActionName: String? = body[KeyConstant.logCustomActionName.rawValue] as? String ?? ClassConstant.LogConstant.defaultLogCustomActionName
        
        var logDate: Date = ClassConstant.LogConstant.defaultLogDate
        if let logDateString = body[KeyConstant.logDate.rawValue] as? String {
            logDate = ResponseUtils.dateFormatter(fromISO8601String: logDateString) ?? ClassConstant.LogConstant.defaultLogDate
        }
        
        let logNote: String = body[KeyConstant.logNote.rawValue] as? String ?? ClassConstant.LogConstant.defaultLogNote
        
        self.init(logId: logId, userId: userId, logAction: logAction, logCustomActionName: logCustomActionName, logDate: logDate, logNote: logNote)
        
        logIsDeleted = body[KeyConstant.logIsDeleted.rawValue] as? Bool ?? false
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
            throw ErrorConstant.LogError.logCustomActionNameCharacterLimitExceeded
        }
        
        logCustomActionName = forLogCustomActionName
    }
    
    var logDate: Date = ClassConstant.LogConstant.defaultLogDate
    
    private(set) var logNote: String = ClassConstant.LogConstant.defaultLogNote
    func changeLogNote(forLogNote: String) throws {
        guard forLogNote.count <= ClassConstant.LogConstant.logNoteCharacterLimit else {
            throw ErrorConstant.LogError.logNoteCharacterLimitExceeded
        }
        
        logNote = forLogNote
    }
    
}

extension Log {
    // MARK: - Request
    
    /// Returns an array literal of the logs's properties. This is suitable to be used as the JSON body for a HTTP request
    func createBody() -> [String: Any] {
        var body: [String: Any] = [:]
        body[KeyConstant.logNote.rawValue] = logNote
        body[KeyConstant.logDate.rawValue] = logDate.ISO8601FormatWithFractionalSeconds()
        body[KeyConstant.logAction.rawValue] = logAction.rawValue
        body[KeyConstant.logCustomActionName.rawValue] = logCustomActionName
        return body
        
    }
}
