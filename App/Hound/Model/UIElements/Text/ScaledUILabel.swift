//
//  ScaledUILabel.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/30/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

// NOT final class
class ScaledUILabel: UILabel {
    
    // MARK: Main
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.adjustsFontSizeToFitWidth = true
        if self.minimumScaleFactor == 0 {
            self.minimumScaleFactor = 0.72
        }
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.adjustsFontSizeToFitWidth = true
        if self.minimumScaleFactor == 0 {
            self.minimumScaleFactor = 0.72
        }
    }
    
    // MARK: Placeholder
    
    /// When the UILabel did change, show or hide the label based on if the UITextView is empty or not
    override var text: String? {
        didSet {
            // Ensure the placeholderLabel exists
            guard let placeholderLabel = self.viewWithTag(VisualConstant.ViewTagConstant.placeholderForScaledUILabel) as? UILabel else {
                return
            }
            
            // Ensure placeholderLabel text exists and isn't ""
            guard let placeholderLabelText = placeholderLabel.text, placeholderLabelText.trimmingCharacters(in: .whitespacesAndNewlines) != "" else {
                placeholderLabel.isHidden = true
                return
            }
            
            togglePlaceholderLabelIsHidden(forPlaceholderLabel: placeholderLabel)
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
            
            if let placeholderLabel = self.viewWithTag(VisualConstant.ViewTagConstant.placeholderForScaledUILabel) as? UILabel {
                placeholderText = placeholderLabel.text
            }
            
            return placeholderText
        }
        set {
            if let placeholderLabel = self.viewWithTag(VisualConstant.ViewTagConstant.placeholderForScaledUILabel) as? UILabel {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            }
            else if let newValue = newValue {
                self.addPlaceholder(newValue)
            }
        }
    }
    
    /// Resize the placeholder UILabel to make sure it's in the same position as the UILabel text
    private func resizePlaceholder() {
        if let placeholderLabel = self.viewWithTag(VisualConstant.ViewTagConstant.placeholderForScaledUILabel) as? UILabel {
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
        placeholderLabel.tag = VisualConstant.ViewTagConstant.placeholderForScaledUILabel
        
        togglePlaceholderLabelIsHidden(forPlaceholderLabel: placeholderLabel)
        
        self.addSubview(placeholderLabel)
        self.resizePlaceholder()
    }
    
    /// Changes the isHidden status of the placeholderLabel passed, based upon the presence and contents of self.text
    private func togglePlaceholderLabelIsHidden(forPlaceholderLabel placeholderLabel: UILabel) {
        if let labelText = self.text {
            // If the text of the ui label exists, then we want to hide the placeholder label (if the ui label text contains actual characters)
            // "anyText" != "" -> true -> hide the placeholder label
            // "" != "" -> false -> show the placeholder label
            placeholderLabel.isHidden = labelText.trimmingCharacters(in: .whitespacesAndNewlines) != ""
        }
        // If the primary text of UILabel is nil, then show the placeholder label!
        else {
            placeholderLabel.isHidden = false
        }
    }
    
}
