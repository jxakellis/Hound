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
    
    
    
    
    //MARK: NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = RequirementLog(date: self.date, note: self.note)
        return copy
    }
    
    //MARK: NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        self.storedDate = aDecoder.decodeObject(forKey: "date") as! Date
        self.storedNote = aDecoder.decodeObject(forKey: "note") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(storedDate, forKey: "date")
        aCoder.encode(storedNote, forKey: "note")
    }
    
    //MARK: RequirementLogProtocol
    
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
