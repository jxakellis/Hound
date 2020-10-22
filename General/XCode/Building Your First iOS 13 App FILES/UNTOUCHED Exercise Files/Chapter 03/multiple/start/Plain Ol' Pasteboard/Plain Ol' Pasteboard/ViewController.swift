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
        showText()
    }
    
    func addText() {
        showText()
    }
    
    func showText() {
        textView.text = UIPasteboard.general.string
    }

    @IBAction func trashWasPressed(_ sender: Any) {
        
    }
    
}

