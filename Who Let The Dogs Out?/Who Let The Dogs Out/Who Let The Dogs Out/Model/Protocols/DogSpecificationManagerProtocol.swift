//
//  DogSpecificationManager.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 11/18/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//



import UIKit

///Enum full of cases of possible errors from DogSpecificationManager
enum DogSpecificationManagerError: Error{
    case nilKey
    case blankKey
    case invalidKey
    case keyNotPresentInGlobalConstantList
    // the strings are the key that the value used
    case nilNewValue(String)
    case blankNewValue(String)
    case invalidNewValue(String)
}

//Used to be code here, but moved to a class instead
