//
//  ReminderLog.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/25/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit



enum ScheduledLogType: String, CaseIterable {
    
    init?(rawValue: String) {
        //backwards compatible
        if rawValue == "Other"{
            self = .custom
            return
        }
        //regular
        for type in ScheduledLogType.allCases{
            if type.rawValue == rawValue{
                self = type
                return
            }
        }
        
        print("scheduledLogType Not Found")
        self = .custom
    }
    //common
    case feed = "Feed"
    case water = "Fresh Water"
    case potty = "Potty"
    case walk = "Walk"
    //next common
    case brush = "Brush"
    case bathe = "Bathe"
    case medicine = "Medicine"
    
    //more common than previous but probably used less by user as weird type
    case sleep = "Sleep"
    case trainingSession = "Training Session"
    case doctor = "Doctor Visit"
    
    case custom = "Custom"
}

enum KnownLogTypeError: Error {
    case nilLogType
    case blankLogType
}

enum KnownLogType: String, CaseIterable {
    
    init?(rawValue: String) {
        //backwards compatible
        if rawValue == "Other"{
            self = .custom
            return
        }
        //regular
        for type in KnownLogType.allCases{
            if type.rawValue == rawValue{
                self = type
                return
            }
        }
        
        print("knownLogType Not Found")
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
    
    case wakeup = "Wake up"
    
    case sleep = "Sleep"
    
    case crate = "Crate"
    case trainingSession = "Training Session"
    case doctor = "Doctor Visit"
    
    case custom = "Custom"
}

protocol KnownLogProtocol{
    
    ///Date at which the log is assigned
    var date: Date { get set }
    
    ///Note attached to the log
    var note: String { get set }
    
    var logType: KnownLogType { get set }
    
    ///If the reminder's type is custom, this is the name for it
    var customTypeName: String? { get set }
    
    ///If not .custom type then just .type name, if custom and has customTypeName then its that string
    var displayTypeName: String { get }
    
    var uuid: String { get set }
    
    
}

class KnownLog: NSObject, NSCoding, NSCopying, KnownLogProtocol{
    
    
    //MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = KnownLog(date: self.date, note: self.note, logType: self.logType, customTypeName: self.customTypeName, uuid: self.uuid)
        return copy
    }
    
    //MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        self.date = aDecoder.decodeObject(forKey: "date") as! Date
        self.note = aDecoder.decodeObject(forKey: "note") as! String
        self.logType = KnownLogType(rawValue: aDecoder.decodeObject(forKey: "logType") as! String)!
        self.customTypeName = aDecoder.decodeObject(forKey: "customTypeName") as? String
        self.uuid = aDecoder.decodeObject(forKey: "uuid") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(date, forKey: "date")
        aCoder.encode(note, forKey: "note")
        aCoder.encode(logType.rawValue, forKey: "logType")
        aCoder.encode(customTypeName, forKey: "customTypeName")
        aCoder.encode(uuid, forKey: "uuid")
    }
    
    //MARK: - ReminderLogProtocol
    
    init(date: Date, note: String = "", logType: KnownLogType, customTypeName: String?, uuid: String? = nil){
        self.date = date
        self.note = note
        self.logType = logType
        self.customTypeName = customTypeName
        if uuid != nil {
            self.uuid = uuid!
        }
        super.init()
    }
    
    var date: Date
    
    var note: String
    
    var logType: KnownLogType
    
    var customTypeName: String?
    
    var displayTypeName: String {
        if logType == .custom && customTypeName != nil {
            return customTypeName!
        }
        else {
            return logType.rawValue
        }
    }
    
    var uuid: String = UUID().uuidString
}


