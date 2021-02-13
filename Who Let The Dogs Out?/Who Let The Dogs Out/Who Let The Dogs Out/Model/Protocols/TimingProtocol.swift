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
    
    func willInitalize(dogManager: DogManager, didUnpause: Bool)
    
    func willReinitalize(dogManager: DogManager)
    
    func willReinitalize(dogName: String, requirementName: String) throws
    
    //func didExecuteTimer(sender: Timer)
    
    func willTogglePause(dogManager: DogManager, newPauseStatus: Bool)
    
    //func invalidateAll()
    
    func invalidate(dogName: String, requirementName: String) throws
    
    
}
