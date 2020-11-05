//
//  MemoryPressureMonitor.swift
//  MemoryWarnings
//
//  Created by Karoly Nyisztor on 6/7/18.
//  Copyright © 2018 Nyisztor, Karoly. All rights reserved.
//

import Foundation

class MemoryPressureMonitor {
    static let shared = MemoryPressureMonitor()
    
    private let memoryDS = DispatchSource.makeMemoryPressureSource(eventMask: [.warning, .critical])
    
    private init() {
        memoryDS.setEventHandler { [weak self] in
            if let event = self?.memoryDS.data,
                self?.memoryDS.isCancelled == false {
                switch event {
                case .warning:
                    print("MemoryPressureMonitor: Low memory warning")
                case .critical:
                    print("MemoryPressureMonitor: Critical memory pressure")
                default:
                    print("MemoryPressureMonitor: Unknown event")
                }
            }
        }
        
        memoryDS.activate()
    }
    
    
    deinit {
        memoryDS.cancel()
    }
}







