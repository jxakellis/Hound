//
//  ViewController.swift
//  Plain Ol' Pasteboard
//
//  Created by Todd Perkins on 9/16/19.
//  Copyright © 2019 Todd Perkins. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = "Hello!"
    }

    @IBAction func trashWasPressed(_ sender: Any) {
        textView.text = "Button was pressed!"
    }
    
}

