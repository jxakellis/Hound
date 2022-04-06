//
//  ScaledUIButton.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/30/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class ScaledUIButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.scaleSymbolPontSize()
    }
    
    private func scaleSymbolPontSize() {
        var smallestDimension: CGFloat {
            if self.frame.width <= self.frame.height {
                return self.frame.width
            }
            else {
                return self.frame.height
            }
        }
        
        if currentImage != nil && currentImage!.isSymbolImage == true {
            DispatchQueue.main.async {
                super.setImage(self.currentImage?.applyingSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: smallestDimension)), for: .normal)
            }
        }
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.scaleSymbolPontSize()
    }
    
    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        super.setImage(image, for: state)
        self.scaleSymbolPontSize()
    }
    
    private var initalColor: UIColor?
    private var initalIsUserInteractionEnabled: Bool?
    private var isQuerying: Bool = false
    func beginQuerying(isBackgroundButton: Bool = false) {
        isQuerying = true
        if isBackgroundButton == false {
            initalIsUserInteractionEnabled = isUserInteractionEnabled
            isUserInteractionEnabled = false
            initalColor = tintColor
            tintColor = UIColor.systemGray2
        }
        spin()
        
        func spin() {
            guard isQuerying == true else {
                return
            }
            // begin spin
            UIView.animate(withDuration: 0.43, delay: 0, options: .curveLinear) {
                
                self.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                
            } completion: { _ in
                guard self.isQuerying == true else {
                    return
                }
                // end spin
                UIView.animate(withDuration: 0.43, delay: 0, options: .curveLinear) {
                    
                    self.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2.0)
                } completion: { _ in
                    guard self.isQuerying == true else {
                        return
                    }
                    spin()
                }
            }
        }
    }
    
    func endQuerying(isBackgroundButton: Bool = false) {
        self.isQuerying = false
        self.transform = .identity
        if isBackgroundButton == false {
            if initalColor != nil {
                self.tintColor = initalColor!
                initalColor = nil
            }
            if initalIsUserInteractionEnabled != nil {
                self.isUserInteractionEnabled = initalIsUserInteractionEnabled!
                initalIsUserInteractionEnabled = nil
            }
        }
    }
    
}
