//
//  BorderedUILabel.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/3/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class BorderedUILabel: ScaledUILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.borderWidth = 0.2
        //self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderColor = UIColor.systemGray2.cgColor
        self.layer.cornerRadius = 5.0
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layer.borderWidth = 0.2
        //self.layer.borderColor = UIColor.lightGray.cgColor
        self.layer.borderColor = UIColor.systemGray2.cgColor
        self.layer.cornerRadius = 5.0
    }
    
    override var text: String? {
        get {
            var withRemovedPadding = super.text
            withRemovedPadding?.removeFirst(2)
            return withRemovedPadding
        }
        set (newString){
            if newString == nil {
                super.text = nil
            }
            else {
                super.text = "  ".appending(newString!)
            }
        }
    }
}
