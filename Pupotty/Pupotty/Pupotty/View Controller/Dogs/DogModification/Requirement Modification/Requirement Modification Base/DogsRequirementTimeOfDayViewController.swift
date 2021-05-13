//
//  DogsRequirementTimeOfDayViewController.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 3/28/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsRequirementTimeOfDayViewControllerDelegate {
    func willDismissKeyboard()
}

class DogsRequirementTimeOfDayViewController: UIViewController, UIGestureRecognizerDelegate {
    
    //MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK: - IB
    
    @IBOutlet private var interWeekdayConstraints: [NSLayoutConstraint]!
    
    @IBOutlet private weak var sunday: ScaledButton!
    @IBOutlet private weak var monday: ScaledButton!
    @IBOutlet private weak var tuesday: ScaledButton!
    @IBOutlet private weak var wednesday: ScaledButton!
    @IBOutlet private weak var thursday: ScaledButton!
    @IBOutlet private weak var friday: ScaledButton!
    @IBOutlet private weak var saturday: ScaledButton!
    
    @IBAction private func toggleWeekdayButton(_ sender: Any) {
        delegate.willDismissKeyboard()
        
        disableOnceAMonth()
        
        timeOfDay.datePickerMode = .time
        
        let senderButton = sender as! ScaledButton
        var targetColor: UIColor!
        
        if senderButton.tintColor == UIColor.systemBlue{
            targetColor = ColorConstant.gray.rawValue
        }
        else {
            targetColor = UIColor.systemBlue
        }
        
        senderButton.isUserInteractionEnabled = false
        UIView.animate(withDuration: AnimationConstant.switchButton.rawValue) {
            senderButton.tintColor = targetColor
        } completion: { (completed) in
            senderButton.isUserInteractionEnabled = true
        }
        
    }
    
    @IBOutlet private weak var onceAMonthButton: ScaledButton!
    
    @IBAction private func toggleOnceAMonthButton(_ sender: Any) {
        delegate.willDismissKeyboard()
        var targetColor: UIColor!
        
        disableWeekdays()
        
        timeOfDay.datePickerMode = .dateAndTime
        
        if onceAMonthButton.tag == 1{
            targetColor = ColorConstant.gray.rawValue
            onceAMonthButton.tag = 0
        }
        else {
            targetColor = UIColor.systemBlue
            onceAMonthButton.tag = 1
        }
        
        onceAMonthButton.isUserInteractionEnabled = false
        UIView.animate(withDuration: AnimationConstant.switchButton.rawValue) {
            self.onceAMonthButton.backgroundColor = targetColor
        } completion: { (completed) in
            self.onceAMonthButton.isUserInteractionEnabled = true
        }
    }
    
    @IBOutlet weak var timeOfDay: UIDatePicker!
    
    @IBAction private func willUpdateTimeOfDay(_ sender: Any) {
        delegate.willDismissKeyboard()
    }
    
    //MARK: - Properties
    
    var delegate: DogsRequirementTimeOfDayViewControllerDelegate! = nil
    
    var passedTimeOfDay: Date? = nil
    
    var passedDayOfMonth: Int? = nil
    var passedWeekDays: [Int]? = [1,2,3,4,5,6,7]
    
    var initalValuesChanged: Bool {
        if self.weekdays != passedWeekDays{
            return true
        }
        else if self.dayOfMonth != passedDayOfMonth{
            return true
        }
        else if self.timeOfDay.date != passedTimeOfDay{
            return true
        }
        return false
    }
    
    //MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        onceAMonthButton.layer.cornerRadius = onceAMonthButton.frame.height/2
        onceAMonthButton.layer.masksToBounds = true
        
        synchronizeWeekdays()
        synchronizeOnceAMonth()
        
        //keep duplicate as without it the user can see the .asyncafter visual scroll, but this duplicate stops a value changed not being called on first value change bug
        if self.passedTimeOfDay != nil {
            self.timeOfDay.date = self.passedTimeOfDay!
        }
        else{
            self.timeOfDay.date = Date.roundDate(targetDate: Date(), roundingInterval: 60.0*5, roundingMethod: .up)
            passedTimeOfDay = timeOfDay.date
        }
        
        //fix bug with datePicker value changed not triggering on first go
        DispatchQueue.main.asyncAfter(deadline: .now()){
            self.timeOfDay.date = self.timeOfDay.date
        }
        
        
    }
    
    private func synchronizeWeekdays(){
        let dayOfWeekButtons = [self.sunday, self.monday, self.tuesday, self.wednesday, self.thursday, self.friday, self.saturday]
        
        for dayOfWeekButton in dayOfWeekButtons {
            dayOfWeekButton!.tintColor = ColorConstant.gray.rawValue
        }
        
        if passedWeekDays != nil {
            timeOfDay.datePickerMode = .time
            for dayOfWeek in passedWeekDays!{
                switch dayOfWeek {
                case 1:
                    sunday.tintColor = .systemBlue
                case 2:
                    monday.tintColor = .systemBlue
                case 3:
                    tuesday.tintColor = .systemBlue
                case 4:
                    wednesday.tintColor = .systemBlue
                case 5:
                    thursday.tintColor = .systemBlue
                case 6:
                    friday.tintColor = .systemBlue
                case 7:
                    saturday.tintColor = .systemBlue
                default:
                    print("unknown day of week: \(dayOfWeek) while synchronizeWeekdays for DogsRequirementTimeOfDayViewController")
                }
            }
        }
        
        
        
    }
    
    private func disableOnceAMonth(){
        onceAMonthButton.isUserInteractionEnabled = false
        onceAMonthButton.tag = 0
        UIView.animate(withDuration: AnimationConstant.switchButton.rawValue) {
            self.onceAMonthButton.backgroundColor = ColorConstant.gray.rawValue
        } completion: { (completed) in
            self.onceAMonthButton.isUserInteractionEnabled = true
        }
    }
    
    ///Converts enabled buttons to an array of day of weeks according to CalendarComponents.weekdays, 1 being sunday and 7 being saturday
    var weekdays: [Int]? {
        if timeOfDay.datePickerMode == .dateAndTime {
            return nil
        }
        else {
            var days: [Int] = []
            let dayOfWeekButtons = [self.sunday, self.monday, self.tuesday, self.wednesday, self.thursday, self.friday, self.saturday]
            
            for dayOfWeekIndex in 0..<dayOfWeekButtons.count{
                if dayOfWeekButtons[dayOfWeekIndex]?.tintColor == .systemBlue{
                    days.append(dayOfWeekIndex+1)
                }
            }
            
            if days.isEmpty == true {
                return nil
            }
            else {
                return days
            }
        }
    }
    
    ///Synchronizes the once a month button to the passed information
    private func synchronizeOnceAMonth(){
        onceAMonthButton!.backgroundColor = ColorConstant.gray.rawValue
        onceAMonthButton!.tag = 0
        
        if passedDayOfMonth != nil {
            timeOfDay.datePickerMode = .dateAndTime
            onceAMonthButton!.backgroundColor = UIColor.systemBlue
            onceAMonthButton!.tag = 1
        }
        
    }
    
    private func disableWeekdays(){
        let dayOfWeekButtons = [self.sunday, self.monday, self.tuesday, self.wednesday, self.thursday, self.friday, self.saturday]
        
        for dayOfWeekButton in dayOfWeekButtons{
            dayOfWeekButton!.isUserInteractionEnabled = false
            UIView.animate(withDuration: AnimationConstant.switchButton.rawValue) {
                dayOfWeekButton!.tintColor = ColorConstant.gray.rawValue
            } completion: { (completed) in
                dayOfWeekButton!.isUserInteractionEnabled = true
            }
        }
    }
    
    ///Returns the day of month selected
    var dayOfMonth: Int? {
        if timeOfDay.datePickerMode == .time {
            return nil
        }
        else {
            let targetDate = timeOfDay.date
            let targetDayOfMonth = Calendar.current.component(.day, from: targetDate)
            return targetDayOfMonth
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        for constraint in interWeekdayConstraints {
            constraint.constant = (8.0/414.0)*self.view.safeAreaLayoutGuide.layoutFrame.width
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
