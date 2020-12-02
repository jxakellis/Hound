//
//  Requirement.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 11/20/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

class Requirement: DogRequirementProtocol {
    var label: String = DogConstant.defaultLabel
    
    var description: String = DogConstant.defaultDescription
    
    var initalizationDate: Date = Date()
    
    var interval: TimeInterval = TimeInterval(DogConstant.timeIntervalConstant)
    
    required init(initDate: Date = Date()) {
        initalizationDate = initDate
    }
    
    
}

class RequirementManager: DogRequirementManagerProtocol {
    var requirements: [Requirement]
    
    required init(initRequirements: [Requirement] = []) {
        requirements = initRequirements
    }
    
}
