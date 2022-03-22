//
//  OneTimeComponents.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/4/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

class OneTimeComponents: Component, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = OneTimeComponents()
        copy.executionDate = self.executionDate
        return copy
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        self.executionDate = aDecoder.decodeObject(forKey: "executionDate") as? Date ?? Date()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(executionDate, forKey: "executionDate")
    }
    
    // MARK: Main
    
    override init() {
        super.init()
    }
    
    convenience init(date: Date?) {
        self.init()
        if date != nil {
            executionDate = date!
        }
    }
    
    // MARK: Properties
    
    /// The Date that the alarm should fire
    var executionDate: Date = Date()
}
