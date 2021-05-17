//
//  DogsRequirementMonthlyViewController.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 5/13/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsRequirementMonthlyViewControllerDelegate {
    func willDismissKeyboard()
}

class DogsRequirementMonthlyViewController: UIViewController, UIGestureRecognizerDelegate {
    
    //MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK: - IB
    @IBOutlet weak var datePicker: UIDatePicker!
    
    @IBAction func didUpdateDatePicker(_ sender: Any) {
        delegate.willDismissKeyboard()
    }
    
    //MARK: - Properties
    
    var delegate: DogsRequirementMonthlyViewControllerDelegate! = nil
    
    var passedTimeOfDay: Date? = nil
    
    var passedDayOfMonth: Int? = nil
    
    var initalValuesChanged: Bool {
        if passedDayOfMonth != dayOfMonth{
            return true
        }
        else if passedTimeOfDay != datePicker.date{
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
        if self.passedTimeOfDay != nil {
            self.datePicker.date = self.passedTimeOfDay!
        }
        else{
            self.datePicker.date = Date.roundDate(targetDate: Date(), roundingInterval: 60.0*5, roundingMethod: .up)
            passedTimeOfDay = datePicker.date
        }
        
        //fix bug with datePicker value changed not triggering on first go
        DispatchQueue.main.asyncAfter(deadline: .now()){
            self.datePicker.date = self.datePicker.date
        }
        
        //datePicker.minimumDate = datePicker.date
       // datePicker.maximumDate = Calendar.current.date(byAdding: .month, value: 1, to: datePicker.date)
        
    }
    
    ///Returns the day of month selected
    var dayOfMonth: Int? {
            let targetDate = datePicker.date
            let targetDayOfMonth = Calendar.current.component(.day, from: targetDate)
            return targetDayOfMonth
    }

}
