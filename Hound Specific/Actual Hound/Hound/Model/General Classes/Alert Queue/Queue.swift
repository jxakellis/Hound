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

class Queue<Element>: NSObject, NSCoding {
    
    required init?(coder aDecoder: NSCoder) {
        elements = aDecoder.decodeObject(forKey: "elements") as! [Element]
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(elements, forKey: "elements")
    }
    
    override init(){
        super.init()
    }
    
    var elements = [Element]()
    
    // MARK: - Operations
    
    func enqueue(_ element: Element) {
        elements.append(element)
    }
    
    func queuePresent() -> Bool {
        return !(elements.isEmpty)
    }
    
    func dequeue() -> Element? {
        guard !elements.isEmpty else {
            return nil
        }
        
        return elements.removeFirst()
        
    }
}
