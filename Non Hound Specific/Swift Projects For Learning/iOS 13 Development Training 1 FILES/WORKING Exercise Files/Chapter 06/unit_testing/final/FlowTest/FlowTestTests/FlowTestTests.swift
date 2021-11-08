//
//  FlowTestTests.swift
//  FlowTestTests
//
//  Created by Todd Perkins on 9/23/19.
//  Copyright © 2019 Todd Perkins. All rights reserved.
//

import XCTest

class FlowTestTests: XCTestCase {

    func testBook() {
        let book = Book()
        XCTAssertEqual(book.title, Book.default_title)
        let book2 = Book(title: "My Book", pageCount: 123)
        XCTAssertEqual(book2.pageCount, 123)
    }

}
