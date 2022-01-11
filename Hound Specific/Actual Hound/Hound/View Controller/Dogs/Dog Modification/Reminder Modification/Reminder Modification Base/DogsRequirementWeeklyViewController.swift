//
//  DogsReminderWeeklyViewController.swift
//  Hound
//
//  Created by Jonathan Xakellis on 3/28/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsReminderWeeklyViewControllerDelegate {
    func willDismissKeyboard()
}

class DogsReminderWeeklyViewController: UIViewController, UIGestureRecognizerDelegate {
    
    //MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK: - IB
    
    @IBOutlet private var interWeekdayConstraints: [NSLayoutConstraint]!
    
    @IBOutlet private weak var sunday: ScaledUIButton!
    @IBOutlet private weak var monday: ScaledUIButton!
    @IBOutlet private weak var tuesday: ScaledUIButton!
    @IBOutlet private weak var wednesday: ScaledUIButton!
    @IBOutlet private weak var thursday: ScaledUIButton!
    @IBOutlet private weak var friday: ScaledUIButton!
    @IBOutlet private weak var saturday: ScaledUIButton!
    
    @IBOutlet private var dayOfWeekBackgrounds: [ScaledUIButton]!
    
    
    @IBAction private func toggleWeekdayButton(_ sender: Any) {
        delegate.willDismissKeyboard()
        
        let senderButton = sender as! ScaledUIButton
        var targetColor: UIColor!
        
        if senderButton.tag == 1{
            targetColor = UIColor.systemGray4
            senderButton.tag = 0
        }
        else {
            targetColor = UIColor.systemBlue
            senderButton.tag = 1
        }
        
        senderButton.isUserInteractionEnabled = false
        UIView.animate(withDuration: AnimationConstant.switchButton.rawValue) {
            senderButton.tintColor = targetColor
        } completion: { (completed) in
            senderButton.isUserInteractionEnabled = true
        }
        
    }
    
    @IBOutlet weak var timeOfDay: UIDatePicker!
    
    @IBAction private func willUpdateTimeOfDay(_ sender: Any) {
        delegate.willDismissKeyboard()
    }
    
    //MARK: - Properties
    
    var delegate: DogsReminderWeeklyViewControllerDelegate! = nil
    
    var passedTimeOfDay: Date? = nil
    
    var passedWeekDays: [Int]? = [1,2,3,4,5,6,7]
    
    var initalValuesChanged: Bool {
        if self.weekdays != passedWeekDays{
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
        
        synchronizeWeekdays()
        
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
        
        dayOfWeekBackgrounds.forEach { background in
            self.view.insertSubview(background, belowSubview: saturday)
            self.view.insertSubview(background, belowSubview: monday)
            self.view.insertSubview(background, belowSubview: tuesday)
            self.view.insertSubview(background, belowSubview: wednesday)
            self.view.insertSubview(background, belowSubview: thursday)
            self.view.insertSubview(background, belowSubview: friday)
            self.view.insertSubview(background, belowSubview: sunday)
        }
    }
    
    private func synchronizeWeekdays(){
        let dayOfWeekButtons = [self.sunday, self.monday, self.tuesday, self.wednesday, self.thursday, self.friday, self.saturday]
        
        for dayOfWeekButton in dayOfWeekButtons {
            dayOfWeekButton!.tintColor = UIColor.systemGray4
            dayOfWeekButton!.tag = 0
        }
        
        if passedWeekDays != nil {
            for dayOfWeek in passedWeekDays!{
                switch dayOfWeek {
                case 1:
                    sunday.tintColor = .systemBlue
                    sunday.tag = 1
                case 2:
                    monday.tintColor = .systemBlue
                    monday.tag = 1
                case 3:
                    tuesday.tintColor = .systemBlue
                    tuesday.tag = 1
                case 4:
                    wednesday.tintColor = .systemBlue
                    wednesday.tag = 1
                case 5:
                    thursday.tintColor = .systemBlue
                    thursday.tag = 1
                case 6:
                    friday.tintColor = .systemBlue
                    friday.tag = 1
                case 7:
                    saturday.tintColor = .systemBlue
                    saturday.tag = 1
                default:
                    AppDelegate.generalLogger.fault("unknown day of week: \(dayOfWeek) while synchronizeWeekdays for DogsReminderWeeklyViewController")
                }
            }
        }
        
        
        
    }
    
    ///Converts enabled buttons to an array of day of weeks according to CalendarComponents.weekdays, 1 being sunday and 7 being saturday
    var weekdays: [Int]? {
            var days: [Int] = []
            let dayOfWeekButtons = [self.sunday, self.monday, self.tuesday, self.wednesday, self.thursday, self.friday, self.saturday]
            
            for dayOfWeekIndex in 0..<dayOfWeekButtons.count{
                if dayOfWeekButtons[dayOfWeekIndex]?.tag == 1{
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
