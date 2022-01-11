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
    
    var pastedStrings: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showText()
    }
    
    func addText() {
        guard let text = UIPasteboard.general.string, !pastedStrings.contains(text) else {
            return
        }
        pastedStrings.append(text)
        showText()
    }
    
    func showText() {
        
    }

    @IBAction func trashWasPressed(_ sender: Any) {
        
    }
    
}

