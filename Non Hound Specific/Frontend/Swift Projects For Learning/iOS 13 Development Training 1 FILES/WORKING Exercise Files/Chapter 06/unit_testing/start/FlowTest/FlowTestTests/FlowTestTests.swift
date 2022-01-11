//
//  FlowTestTests.swift
//  FlowTestTests
//
//  Created by Jonathan Xakellis on 10/27/20.
//  Copyright © 2020 Todd Perkins. All rights reserved.
//

import XCTest

class FlowTestTests: XCTestCase {

    func testBook(){
        //red errors are XCode 11 bug
        let book = Book()
        XCTAssertEqual(book.title, Book.default_title)
        let book2 = Book(title: "My Book", pageCount: 123)
        XCTAssertEqual(book2.pageCount, 123)
        
    }

}
