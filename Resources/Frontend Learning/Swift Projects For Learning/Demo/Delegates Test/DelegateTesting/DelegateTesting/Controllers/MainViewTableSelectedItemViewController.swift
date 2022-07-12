//
//  MainViewTableSelectedItemViewController.swift
//  DelegateTesting
//
//  Created by Jonathan Xakellis on 10/29/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

class MainViewTableSelectedItemViewController: UIViewController {

    var sentTableRowItem: Item = Item(name: "def", description: "none", value: -1)
    var sentTableRow: Int = -1
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = "Selected Item Information\nRow: \(sentTableRow) \nText: \(sentTableRowItem.stringReadout())"
    }
    
    // MARK: - Navigation
    
    @IBAction func backButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func doneButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }


}
