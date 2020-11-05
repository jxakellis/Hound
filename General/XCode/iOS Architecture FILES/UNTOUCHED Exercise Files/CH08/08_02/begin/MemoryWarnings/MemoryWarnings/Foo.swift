//
//  Foo.swift
//  MemoryWarnings
//
//  Created by Karoly Nyisztor on 6/7/18.
//  Copyright © 2018 Nyisztor, Karoly. All rights reserved.
//

import Foundation

struct Foo {
    init() {
        NotificationCenter.default.addObserver(forName: .UIApplicationDidReceiveMemoryWarning, object: nil, queue: nil) { (notification) in
            print("\(#function) received notification \(notification)")
        }
    }
}
