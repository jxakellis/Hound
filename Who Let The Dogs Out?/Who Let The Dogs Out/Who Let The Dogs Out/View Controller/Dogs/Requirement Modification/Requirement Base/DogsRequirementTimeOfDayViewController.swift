//
//  DogsRequirementTimeOfDayViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 3/28/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsRequirementTimeOfDayViewControllerDelegate {
    func willDismissKeyboard()
}

class DogsRequirementTimeOfDayViewController: UIViewController, UIGestureRecognizerDelegate {
    
    //MARK: UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK: IB
    
    @IBOutlet weak var timeOfDay: UIDatePicker!
    
    @IBAction func willUpdateTimeOfDay(_ sender: Any) {
        delegate.willDismissKeyboard()
    }
    
    //MARK: Properties
    
    var delegate: DogsRequirementTimeOfDayViewControllerDelegate! = nil
    
    var passedTimeOfDay: Date?
    
    //MARK: Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if passedTimeOfDay != nil {
            timeOfDay.date = passedTimeOfDay!
        }
        else{
            timeOfDay.date = Date()
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
