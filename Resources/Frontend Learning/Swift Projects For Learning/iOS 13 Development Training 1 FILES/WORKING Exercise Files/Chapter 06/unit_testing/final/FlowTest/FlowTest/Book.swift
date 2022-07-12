//
//  Book.swift
//  UnitTesting
//
//  Created by Todd Perkins on 9/18/19.
//  Copyright © 2019 Todd Perkins. All rights reserved.
//

import UIKit

class Book: NSObject {
    
    static let default_title = "Name"
    
    var title: String = default_title
    var pageCount: Int = 0
    
    override init() {
        
    }
    
    init(title: String, pageCount: Int) {
        self.title = title
        self.pageCount = pageCount
    }

}
