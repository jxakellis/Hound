//
//  DogRequirementManager.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 11/20/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum DogRequirementError: Error {
    
}

protocol DogRequirementProtocol {
    //taking the dog to the bathroom
    //label
    //
    var label: String { get set }
    
    var initDate: Date { get set }
    
    init(date: Date)
}

protocol DogRequirementManagerProtocol {
    
    //var requirements: Requirement { get set }
    
    mutating func clearRequirements()
}
