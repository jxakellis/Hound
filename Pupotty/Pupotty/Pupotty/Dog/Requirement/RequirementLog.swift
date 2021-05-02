//
//  RequirementLog.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 4/25/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol RequirementLogProtocol{
    ///Date at which the log was taken
    var date: Date { get }
    
    ///Note attached to the log
    var note: String { get }
    ///Changes note
    func changeNote(newNote: String)
}

class RequirementLog: NSObject, NSCoding, NSCopying, RequirementLogProtocol{
    
    
    //MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = RequirementLog(date: self.date, note: self.note)
        return copy
    }
    
    //MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        self.storedDate = aDecoder.decodeObject(forKey: "date") as! Date
        self.storedNote = aDecoder.decodeObject(forKey: "note") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(storedDate, forKey: "date")
        aCoder.encode(storedNote, forKey: "note")
    }
    
    //MARK: - RequirementLogProtocol
    
    init(date: Date, note: String = ""){
        storedDate = date
        storedNote = note
        super.init()
    }
    
    private var storedDate: Date
    var date: Date { return storedDate }
    
    private var storedNote: String
    var note: String { return storedNote }
    func changeNote(newNote: String){
        storedNote = newNote
    }
    
    
}

enum ArbitraryLogError: Error {
    case nilLogName
    case blankLogName
}

protocol ArbitraryLogProtcol{
    /*
     var requirementName: String { return storedRequirementName }
     func changeRequirementName(newRequirementName: String?) throws {
         if newRequirementName == nil || newRequirementName == "" {
             throw RequirementError.nameBlank
         }
         storedRequirementName = newRequirementName!
     }
     */
    
    var uuid: String { get set }
    
    var creationDate: Date { get set }
    
    var logName: String { get }
    func changeLogName(newLogName: String?) throws
}

class ArbitraryLog: RequirementLog, ArbitraryLogProtcol{
    
    //MARK: - RequirementLog
    
    override func copy(with zone: NSZone? = nil) -> Any {
        let copy = ArbitraryLog(date: self.date, note: self.note)
        copy.storedLogName = self.logName
        copy.uuid = self.uuid
        copy.creationDate = self.creationDate
        return copy
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.uuid = aDecoder.decodeObject(forKey: "uuid") as! String
        self.creationDate = aDecoder.decodeObject(forKey: "creationDate") as! Date
    }
    
    override func encode(with aCoder: NSCoder) {
        super.encode(with: aCoder)
        aCoder.encode(uuid, forKey: "uuid")
        aCoder.encode(creationDate, forKey: "creationDate")
    }
    
    //MARK: - RequirementLogProtocol
    
    override init(date: Date, note: String = ""){
        super.init(date: date, note: note)
    }
    
    
    //MARK: - ArbitraryLogProtocol
    
    var uuid: String = UUID().uuidString
    
    var creationDate: Date = Date()
    
    private var storedLogName: String = RequirementConstant.defaultName
    var logName: String { return storedLogName }
    
    func changeLogName(newLogName: String?) throws {
        if newLogName == nil {
            throw ArbitraryLogError.nilLogName
        }
        else if newLogName?.trimmingCharacters(in: .whitespacesAndNewlines) == ""{
            throw ArbitraryLogError.blankLogName
        }
        else {
            storedLogName = newLogName!
        }
    }
    
    
}
