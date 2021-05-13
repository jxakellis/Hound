//
//  DogsRequirementCountDownViewController.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 3/28/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsRequirementCountDownViewControllerDelegate {
    func willDismissKeyboard()
}

class DogsRequirementCountDownViewController: UIViewController, UIGestureRecognizerDelegate {
    
    //MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    

    //MARK: - IB
    
    @IBOutlet weak var countDown: UIDatePicker!
    
    @IBAction func willUpdateCountDown(_ sender: Any) {
        delegate.willDismissKeyboard()
    }
    
    //MARK: - Properties
    
   var delegate: DogsRequirementCountDownViewControllerDelegate! = nil
    
    var passedInterval: TimeInterval? = nil
    
    var initalValuesChanged: Bool {
        if countDown.countDownDuration != passedInterval{
            return true
        }
        else {
            return false
        }
    }
    //MARK: - Main
    
    override func viewDidLoad() {
        
        //keep duplicate as without it the user can see the .asyncafter visual scroll, but this duplicate stops a value changed not being called on first value change bug
        if self.passedInterval != nil {
            self.countDown.countDownDuration = self.passedInterval!
        }
        else {
            self.countDown.countDownDuration = RequirementConstant.defaultTimeInterval
            passedInterval = countDown.countDownDuration
        }
        
        //fix bug with datePicker value changed not triggering on first go
        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if self.passedInterval != nil {
                self.countDown.countDownDuration = self.passedInterval!
            }
            else {
                self.countDown.countDownDuration = RequirementConstant.defaultTimeInterval
            }
        }
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
