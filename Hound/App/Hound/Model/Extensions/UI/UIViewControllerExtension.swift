//
//  UIViewControllerExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/30/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

extension UIViewController {
    
    func setupToHideKeyboardOnTapOnView() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func performSegueOnceInWindowHierarchy(segueIdentifier: String) {
        
        waitLoop()
        
        func waitLoop () {
            if self.isViewLoaded && self.view.window != nil {
                self.performSegue(withIdentifier: segueIdentifier, sender: self)
            }
            else {
                AppDelegate.generalLogger.warning("waitloop for performSegueOnceInWindowHierarchy")
                DispatchQueue.main.asyncAfter(deadline: .now()+0.05) {
                    waitLoop()
                }
            }
        }
    }
    
    private func performSpinningAnimation(forForegroundImage foregroundImage: UIImage?, forForegroundColor foregroundColor: UIColor, forBackgroundImage backgroundImage: UIImage?) {
        
        // align center x
        // align center y
        // 1:1 ratio
        // proportional width to safe area (90/414)
        // <= 90 width
        var imageViewWidth: Double {
            // hopefully 414 points but if (for example) bigger phone could be 500 or smaller phone could be 300
            let safeAreaWidth = self.view.safeAreaLayoutGuide.layoutFrame.width
            
            // we want the image to be 90 points on a 414 point screen
            let idealWidth = 90.0 * 1.5
            let idealSafeAreaWidth = 414.0
            
            // the ideal ratio of how wide the button is to how wide the safe area is
            let idealRatio = idealWidth / idealSafeAreaWidth
            
            // if the image were to conform to the ideal ratio of its width to the safe area width, this is how width it would be (in points)
            let actualWidth = idealRatio * safeAreaWidth
            
            // we don't want the image to exceed the ideal width (90.0). Return actual if it's <= ideal. Otherwise, return ideal if it's > ideal
            return actualWidth <= idealWidth ? actualWidth : idealWidth
        }
        
        let foregroundImageView = UIImageView(image: foregroundImage)
        let foregroundImageViewConstraints = [
            // 0, align centers
            foregroundImageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            // 1, aligh centers
            foregroundImageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            // 2, make it a square
            foregroundImageView.heightAnchor.constraint(equalToConstant: imageViewWidth),
            // 3, make it the correct width
            foregroundImageView.widthAnchor.constraint(equalToConstant: imageViewWidth)
        ]
        foregroundImageView.translatesAutoresizingMaskIntoConstraints = false
        foregroundImageView.tintColor = foregroundColor
        
        self.view.addSubview(foregroundImageView)
        NSLayoutConstraint.activate(foregroundImageViewConstraints)
        
        let backgroundImageView = UIImageView(image: backgroundImage)
        let backgroundImageViewConstraints = [
            backgroundImageView.leadingAnchor.constraint(equalTo: foregroundImageView.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: foregroundImageView.trailingAnchor),
            backgroundImageView.topAnchor.constraint(equalTo: foregroundImageView.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: foregroundImageView.bottomAnchor)
        ]
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        backgroundImageView.tintColor = UIColor.white
        
        self.view.addSubview(backgroundImageView)
        NSLayoutConstraint.activate(backgroundImageViewConstraints)
        
        // make foreground in front of background
        self.view.bringSubviewToFront(foregroundImageView)
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        foregroundImageView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        foregroundImageView.alpha = 0.0
        backgroundImageView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        backgroundImageView.alpha = 0.0
        
        let duration: TimeInterval = 0.17
        
        // come in from nothing
        UIView.animate(withDuration: duration, delay: 0, options: .curveEaseOut, animations: {
            
            foregroundImageView.transform = .identity
            foregroundImageView.alpha = 1.0
            backgroundImageView.transform = .identity
            backgroundImageView.alpha = 1.0
            
        }) { _ in
            
            // begin spin once
            UIView.animate(withDuration: duration, delay: 0, options: .curveLinear) {
                
                foregroundImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                backgroundImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
                
            } completion: { _ in
                // finished
            }
            
            // end spin
            UIView.animate(withDuration: duration, delay: (duration*0.85), options: .curveEaseIn) {
                
                foregroundImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2.0)
                backgroundImageView.transform = CGAffineTransform(rotationAngle: CGFloat.pi * 2.0)
                
            } completion: { _ in
                
                // get small and disappear
                UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn) {
                    
                    foregroundImageView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                    foregroundImageView.alpha = 0.0
                    backgroundImageView.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
                    backgroundImageView.alpha = 0.0
                    
                } completion: { _ in
                    
                    // done with everything
                    foregroundImageView.removeFromSuperview()
                    backgroundImageView.removeFromSuperview()
                }
            }
            
        }
    }
    
    func performSpinningCheckmarkAnimation() {
        
        performSpinningAnimation(forForegroundImage: UIImage.init(systemName: "checkmark.circle.fill"), forForegroundColor: UIColor.systemGreen, forBackgroundImage: UIImage.init(systemName: "circle.fill"))
        
    }
    
    func performSpinningUndoAnimation() {
        
        performSpinningAnimation(forForegroundImage: UIImage.init(systemName: "arrow.uturn.backward.circle.fill"), forForegroundColor: UIColor.systemGray2, forBackgroundImage: UIImage.init(systemName: "circle.fill"))
        
    }
}
