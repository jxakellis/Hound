//
//  DogsRequirementOnceViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/30/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsRequirementOnceViewControllerDelegate {
    func willDismissKeyboard()
}

class DogsRequirementOnceViewController: UIViewController, UIGestureRecognizerDelegate {

    //MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK: - IB
    @IBOutlet private weak var datePicker: UIDatePicker!
    
    @IBAction private func didUpdateDatePicker(_ sender: Any) {
        delegate.willDismissKeyboard()
    }
    
    //MARK: - Properties
    
    var delegate: DogsRequirementOnceViewControllerDelegate! = nil
    
    var passedDate: Date? = nil
    
    var initalValuesChanged: Bool {
        if passedDate != datePicker.date{
            return true
        }
        else {
            return false
        }
    }
    
    //MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //keep duplicate as without it the user can see the .asyncafter visual scroll, but this duplicate stops a value changed not being called on first value change bug
        if self.passedDate != nil {
            self.datePicker.date = self.passedDate!
        }
        else{
            self.datePicker.date = Date.roundDate(targetDate: Date(), roundingInterval: 60.0*5, roundingMethod: .up)
            passedDate = datePicker.date
        }
        
        //fix bug with datePicker value changed not triggering on first go
        DispatchQueue.main.asyncAfter(deadline: .now()){
            self.datePicker.date = self.datePicker.date
        }
        
        datePicker.minimumDate = datePicker.date
        
    }
    
    ///Returns the datecomponets  selected
    var dateComponents: DateComponents? {
        if Date().distance(to: datePicker.date) < 0{
            datePicker.date = datePicker.date.addingTimeInterval(5.0*60.0)
        }
        return Calendar.current.dateComponents([.year,.month,.day,.hour,.minute], from: datePicker.date)
    }

}
