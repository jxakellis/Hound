//
//  TimingProtocol.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/10/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol TimingProtocol {
    
    //init(dogManager: DogManager)
    
    func willInitalize()
    
    func willReinitalize()
    
    func willReinitalize(dogName: String, requirementName: String) throws
    
    func didExecuteTimer(sender: Timer)
    
    func willTogglePause(pasueStatus: Bool)
    
    func invalidateAll()
    
    func invalidate(dogName: String, requirementName: String) throws
    
    
}
