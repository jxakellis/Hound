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

extension UIColor {

    func rgb() -> (red:Int, green:Int, blue:Int, alpha:Int)? {
        var fRed : CGFloat = 0
        var fGreen : CGFloat = 0
        var fBlue : CGFloat = 0
        var fAlpha: CGFloat = 0
        if self.getRed(&fRed, green: &fGreen, blue: &fBlue, alpha: &fAlpha) {
            let iRed = Int(fRed * 255.0)
            let iGreen = Int(fGreen * 255.0)
            let iBlue = Int(fBlue * 255.0)
            let iAlpha = Int(fAlpha * 255.0)

            return (red:iRed, green:iGreen, blue:iBlue, alpha:iAlpha)
        } else {
            // Could not extract RGBA components:
            return nil
        }
    }
}


