//
//  Requirement.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 11/20/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

class Requirement: DogRequirementProtocol {
    var label: String = ""
    
    var description: String = ""
    
    var initalizationDate: Date = Date()
    
    var interval: TimeInterval = 3600
    
    required init(initDate: Date = Date(), initInterval: TimeInterval = TimeInterval(3600)) {
        initalizationDate = initDate
        interval = initInterval
    }
    
    
}

//class RequirementManager: DogRequirementManagerProtocol {
    //var requirements: Requirement
//}
