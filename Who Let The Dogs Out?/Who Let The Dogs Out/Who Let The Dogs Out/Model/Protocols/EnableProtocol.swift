//
//  EnableProtocol.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/6/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol EnableProtocol {
    
    //var isEnabled: Bool { get set }
    
    ///Changes isEnabled to newEnableStatus
    func setEnable(newEnableStatus: Bool)
    
    ///Toggles isEnabled
    func willToggle()
    
    ///Returns isEnabled state
    func getEnable() -> Bool
    
}
