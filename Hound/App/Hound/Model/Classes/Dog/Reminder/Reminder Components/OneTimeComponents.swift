//
//  OneTimeComponents.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/4/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

final class OneTimeComponents: NSObject, NSCoding, NSCopying {
    
    // MARK: - NSCopying
    
    func copy(with zone: NSZone? = nil) -> Any {
        let copy = OneTimeComponents()
        copy.oneTimeDate = self.oneTimeDate
        return copy
    }
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        self.oneTimeDate = aDecoder.decodeObject(forKey: "oneTimeDate") as? Date ?? Date()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(oneTimeDate, forKey: "oneTimeDate")
    }
    
    // MARK: Main
    
    override init() {
        super.init()
    }
    
    convenience init(date: Date?) {
        self.init()
        if date != nil {
            oneTimeDate = date!
        }
    }
    
    // MARK: Properties
    
    /// The Date that the alarm should fire
    var oneTimeDate: Date = Date()
}
