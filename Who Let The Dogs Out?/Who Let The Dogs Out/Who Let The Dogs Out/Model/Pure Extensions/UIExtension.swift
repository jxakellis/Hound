//
//  UIViewControllerExtension.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/18/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

extension UIViewController
{
    
    func setupToHideKeyboardOnTapOnView()
    {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard()
    {
        view.endEditing(true)
    }
}

extension UITableView {
    /// Deselects all rows
    func deselectAll(){
        if indexPathsForSelectedRows != nil{
            for indexPath in self.indexPathsForSelectedRows! {
                self.deselectRow(at: indexPath, animated: false)
            }
        }
    }
    
    
}

class ScaledButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.scaleSymbolPontSize()
    }
    
    private func scaleSymbolPontSize(){
        var smallestDimension: CGFloat {
            if self.frame.width <= self.frame.height {
                return self.frame.width
            }
            else {
                return self.frame.height
            }
        }
        self.setImage(self.currentImage?.applyingSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: smallestDimension)), for: .normal)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.scaleSymbolPontSize()
    }
    
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        super.setImage(image, for: state)
        if image != nil && image!.isSymbolImage == true {
            DispatchQueue.main.async {
                self.scaleSymbolPontSize()
            }
        }
    }
    
}

class CustomLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.adjustsFontSizeToFitWidth = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.adjustsFontSizeToFitWidth = true
    }
    
}

extension UILabel {
    /*
     func makeOutLine(oulineColor: UIColor, foregroundColor: UIColor{
             let strokeTextAttributes = [
                 NSAttributedString.Key.strokeColor : oulineColor,
                 NSAttributedString.Key.foregroundColor : foregroundColor,
                 NSAttributedString.Key.strokeWidth : -4.0,
                 NSAttributedString.Key.font : font ?? UIFont.systemFontSize
                 ] as [NSAttributedString.Key : Any]
             self.attributedText = NSMutableAttributedString(string: self.text ?? "", attributes: strokeTextAttributes)
         }
     */
    
    func outline(outlineColor: UIColor, insideColor foregroundColor: UIColor, outlineWidth: CGFloat){
        let strokeTextAttributes = [
            NSAttributedString.Key.strokeColor : outlineColor,
            NSAttributedString.Key.foregroundColor : foregroundColor,
            NSAttributedString.Key.strokeWidth : outlineWidth,
            NSAttributedString.Key.font : font ?? UIFont.systemFontSize
            ] as [NSAttributedString.Key : Any]
        self.attributedText = NSMutableAttributedString(string: self.text ?? "", attributes: strokeTextAttributes)
    }
}

