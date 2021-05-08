//
//  RequirementLog.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 4/25/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit



enum ScheduledLogType: String, CaseIterable {
    case feed = "Feed"
    case potty = "Potty"
    case walk = "Walk"
    case sleep = "Sleep"
    case crate = "Crate"
    case other = "Other"
}

enum KnownLogTypeError: Error {
    case nilLogType
    case blankLogType
}

enum KnownLogType: String, CaseIterable {
    
    case feed = "Feed"
    
    case pee = "Potty: Pee"
    case poo = "Potty: Poo"
    case both = "Potty: Both"
    case neither = "Potty: Didn't Go"
    
    case accident = "Accident"
    
    case walk = "Walk"
    
    case wakeup = "Wake up"
    
    case sleep = "Sleep"
    case crate = "Crate"
    case other = "Other"
}

protocol KnownLogProtocol{
    
    ///Date at which the log is assigned
    var date: Date { get set }
    
    ///Note attached to the log
    var note: String { get set }
    
    var logType: KnownLogType { get set }
    
    var uuid: String { get set }
    
    ///Physical creation date of the log
    var creationDate: Date { get set }
    
}

class KnownLog: NSObject, NSCoding, NSCopying, KnownLogProtocol{
    
    
    //MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = KnownLog(date: self.date, note: self.note, logType: self.logType, creationDate: self.creationDate, uuid: self.uuid)
        return copy
    }
    
    //MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        self.date = aDecoder.decodeObject(forKey: "date") as! Date
        self.note = aDecoder.decodeObject(forKey: "note") as! String
        self.logType = KnownLogType(rawValue: aDecoder.decodeObject(forKey: "logType") as! String)!
        self.creationDate = aDecoder.decodeObject(forKey: "creationDate") as! Date
        self.uuid = aDecoder.decodeObject(forKey: "uuid") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(date, forKey: "date")
        aCoder.encode(note, forKey: "note")
        aCoder.encode(logType.rawValue, forKey: "logType")
        aCoder.encode(creationDate, forKey: "creationDate")
        aCoder.encode(uuid, forKey: "uuid")
    }
    
    //MARK: - RequirementLogProtocol
    
    init(date: Date, note: String = "", logType: KnownLogType, creationDate: Date = Date(), uuid: String? = nil){
        self.date = date
        self.note = note
        self.logType = logType
        self.creationDate = creationDate
        if uuid != nil {
            self.uuid = uuid!
        }
        super.init()
    }
    
    var date: Date
    
    var note: String
    
    var logType: KnownLogType
    
    var creationDate: Date
    
    var uuid: String = UUID().uuidString
}


