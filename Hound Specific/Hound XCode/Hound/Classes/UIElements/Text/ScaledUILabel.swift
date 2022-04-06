//
//  ScaledUILabel.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/30/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class ScaledUILabel: UILabel {
    
    // MARK: Main
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.adjustsFontSizeToFitWidth = true
        if self.minimumScaleFactor == 0 {
            self.minimumScaleFactor = 0.82
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.adjustsFontSizeToFitWidth = true
        if self.minimumScaleFactor == 0 {
            self.minimumScaleFactor = 0.82
        }
    }
    
    // MARK: Placeholder
    
    /// When the UILabel did change, show or hide the label based on if the UITextView is empty or not
    override var text: String? {
        didSet {
            if let placeholderLabel = self.viewWithTag(ViewTagConstant.placeholderForScaledUILabel.rawValue) as? UILabel {
                guard placeholderLabel.text?.isEmpty == false else {
                    return
                }
                if self.text == nil {
                    placeholderLabel.isHidden = false
                }
                else {
                    placeholderLabel.isHidden = !self.text!.isEmpty
                }
            }
        }
    }
    
    /// Resize the placeholder when the UILabel bounds change
    override open var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    /// The UILabel placeholder text
    public var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(ViewTagConstant.placeholderForScaledUILabel.rawValue) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(ViewTagConstant.placeholderForScaledUILabel.rawValue) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            }
            else {
                self.addPlaceholder(newValue!)
            }
        }
    }
    
    /// Resize the placeholder UILabel to make sure it's in the same position as the UILabel text
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(ViewTagConstant.placeholderForScaledUILabel.rawValue) as! UILabel? {
            // let labelX = self.frame.minX
            // let labelY = self.frame.minY
            // let labelWidth = self.frame.width - (labelX * 2)
            //  let labelHeight = placeholderLabel.frame.height
            
            // placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
            placeholderLabel.frame = self.bounds
        }
    }
    
    /// Adds a placeholder UILabel to this UILabel
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()
        
        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()
        
        placeholderLabel.font = self.font
        placeholderLabel.textColor = UIColor.systemGray3
        placeholderLabel.tag = ViewTagConstant.placeholderForScaledUILabel.rawValue
        
        if self.text == nil {
            placeholderLabel.isHidden = false
        }
        else {
            placeholderLabel.isHidden = !self.text!.isEmpty
        }
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
    }
    
}
