//
//  LocalDogIcon.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/7/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

class LocalDogIcon: NSObject, NSCoding {
    
    // MARK: - NSCoding
    
    required init?(coder aDecoder: NSCoder) {
        dogId = aDecoder.decodeInteger(forKey: "dogId")
        dogIcon = aDecoder.decodeObject(forKey: "dogIcon") as? UIImage ?? DogConstant.defaultDogIcon
        super.init()
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(dogId, forKey: "dogId")
        aCoder.encode(dogIcon, forKey: "dogIcon")
    }
    
    // MARK: - Main
    
    init(forDogId dogId: Int, forDogIcon dogIcon: UIImage) {
        self.dogId = dogId
        self.dogIcon = dogIcon
        super.init()
    }
    
    // MARK: - Properties
    
    var dogId: Int
    var dogIcon: UIImage
    
}
