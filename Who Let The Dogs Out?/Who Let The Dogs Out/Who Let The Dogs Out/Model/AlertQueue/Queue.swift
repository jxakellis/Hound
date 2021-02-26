//
//  Queue.swift
//  AlertQueue-Example
//
//  Created by William Boles on 08/06/2019.
//  Copyright © 2019 William Boles. All rights reserved.
//
//  Modified by Jonathan Xakellis on 2/5/21.
//

import Foundation

struct Queue<Element> {
    var elements = [Element]()
    
    // MARK: - Operations
    
    mutating func enqueue(_ element: Element) {
        elements.append(element)
    }
    
    func queuePresent() -> Bool {
        return !(elements.isEmpty)
    }
    
    mutating func dequeue() -> Element? {
        guard !elements.isEmpty else {
            return nil
        }
        
        return elements.removeFirst()
        
    }
}
