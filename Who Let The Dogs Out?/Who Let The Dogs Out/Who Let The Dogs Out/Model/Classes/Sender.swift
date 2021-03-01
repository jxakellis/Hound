//
//  Sender.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/28/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class Sender {
    
    let origin: AnyObject?
    var localized: AnyObject?
    
    init(origin: AnyObject, localized: AnyObject){
        if origin is Sender{
            let castedSender = origin as! Sender
            self.origin = castedSender.origin
        }
        else {
            self.origin = origin
        }
        if localized is Sender {
            fatalError("localized cannot be sender")
        }
        else{
            self.localized = localized
        }
    }
    
}
