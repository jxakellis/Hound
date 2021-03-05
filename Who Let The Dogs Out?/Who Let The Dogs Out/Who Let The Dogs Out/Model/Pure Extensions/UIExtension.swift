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
        self.setImage(self.currentImage?.applyingSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: self.frame.width)), for: .normal)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setImage(self.currentImage?.applyingSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: self.frame.width)), for: .normal)
    }
    
    
}

