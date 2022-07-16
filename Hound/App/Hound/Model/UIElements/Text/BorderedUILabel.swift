//
//  BorderedUILabel.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/3/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

final class BorderedUILabel: ScaledUILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.masksToBounds = true
        self.layer.borderWidth = 0.2
        self.layer.borderColor = UIColor.systemGray2.cgColor
        self.layer.cornerRadius = 5.0
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.layer.masksToBounds = true
        self.layer.borderWidth = 0.2
        self.layer.borderColor = UIColor.systemGray2.cgColor
        self.layer.cornerRadius = 5.0
    }
    
     override var text: String? {
        get {
            // remove 2 space offset before returning
            var withRemovedPadding = super.text
            withRemovedPadding?.removeFirst(2)
            return withRemovedPadding
        }
        set {
            // set bordered label text
            if newValue == nil {
                super.text = nil
            }
            else {
                // add 2 space offset
                super.text = "  ".appending(newValue!)
            }
            
            // check to see placeholderlabel exists
            if let placeholderLabel = self.viewWithTag(VisualConstant.ViewTagConstant.placeholderForBorderedUILabel) as? UILabel {
                // check to see if placeholder label has actual text in it
                guard placeholderLabel.text != nil && placeholderLabel.text!.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
                    return
                }
                // unhide placeholder if there is no text in the bordered label
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
    override var bounds: CGRect {
        didSet {
            self.resizePlaceholder()
        }
    }
    
    /// The UILabel placeholder text
    override var placeholder: String? {
        get {
            var placeholderText: String?
            
            if let placeholderLabel = self.viewWithTag(VisualConstant.ViewTagConstant.placeholderForBorderedUILabel) as? UILabel {
                var withRemovedPadding = placeholderLabel.text
                withRemovedPadding?.removeFirst(2)
                placeholderText = withRemovedPadding
            }
            
            return placeholderText
        }
        set {
            // add two space offset to placeholder label.
            if let placeholderLabel = self.viewWithTag(VisualConstant.ViewTagConstant.placeholderForBorderedUILabel) as? UILabel {
                // placeholder label exists
                if newValue == nil {
                    placeholderLabel.text = nil
                }
                else {
                    placeholderLabel.text = "  ".appending(newValue!)
                }
                placeholderLabel.sizeToFit()
            }
            else {
                // need to make placeholder label
                self.addPlaceholder("  ".appending(newValue!))
            }
        }
    }
    
    /// Resize the placeholder UILabel to make sure it's in the same position as the UILabel text
     private func resizePlaceholder() {
         if let placeholderLabel = self.viewWithTag(VisualConstant.ViewTagConstant.placeholderForBorderedUILabel) as? UILabel {
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
        placeholderLabel.tag = VisualConstant.ViewTagConstant.placeholderForBorderedUILabel
        
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
