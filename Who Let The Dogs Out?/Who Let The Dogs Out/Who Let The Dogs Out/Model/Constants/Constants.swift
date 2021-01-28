//
//  Constants.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 12/1/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum DogConstant {
    
    //convert to tuple so the defaults for the keys are directly linked.
    //static let defaultLabel = ""
    //static let defaultDescription = ""
    //static let defaultBreed = ""
    private static let nameTuple: (String, String) = ("name", "Fido")
    private static let descriptionTuple: (String, String) = ("description", "Fiesty")
    private static let breedTuple: (String, String) = ("breed", "Golden Retriever")
    static let defaultDogSpecificationKeys = [nameTuple, descriptionTuple, breedTuple]
}

enum RequirementConstant {
    static let defaultLabel = "Potty"
    static let defaultDescription = "Take Dog Out"
    static let defaultTimeInterval = (3600*2.5)
}
