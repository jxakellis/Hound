//
//  TimingProtocol.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/10/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum TimingError: Error{
    case parseSenderInfoFailed
    case invalidateFailed
}

protocol TimingProtocol {
    
    //init(dogManager: DogManager)
    
    static func willInitalize(dogManager: DogManager, didUnpause: Bool)
    
    static func willReinitalize(dogManager: DogManager)
    
    static func willReinitalize(dogName: String, requirementName: String) throws
    
    //func didExecuteTimer(sender: Timer)
    
    static func willTogglePause(dogManager: DogManager, newPauseStatus: Bool)
    
    //func invalidateAll()
    
    static func invalidate(dogName: String, requirementName: String) throws
    
    
}
