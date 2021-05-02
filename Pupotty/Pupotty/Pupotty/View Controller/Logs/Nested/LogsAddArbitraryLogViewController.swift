//
//  LogsAddArbitraryLogViewController.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 4/30/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol LogsAddArbitraryLogViewControllerDelegate {
    func didAddArbitraryLog(sender: Sender, parentDogName: String, newArbitraryLog: ArbitraryLog) throws
}

class LogsAddArbitraryLogViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //MARK: - IB
    
    @IBOutlet private weak var logDisclaimer: CustomLabel!
    
    @IBOutlet private weak var logName: UITextField!
    
    @IBOutlet private weak var logNote: UITextField!
    
    @IBOutlet private weak var logDate: UIDatePicker!
    
    @IBOutlet private weak var addLogButton: ScaledButton!
    
    @IBOutlet private weak var addLogButtonBackground: ScaledButton!
    
    @IBOutlet private weak var cancelAddLogButton: ScaledButton!
    
    @IBOutlet private weak var cancelAddLogButtonBackground: ScaledButton!
    
    @IBAction private func willAddLog(_ sender: Any) {
        self.dismissKeyboard()
        let arbitraryLog = ArbitraryLog(date: logDate.date, note: logNote.text ?? "")
        
        do {
            try arbitraryLog.changeLogName(newLogName: logName.text)
            try delegate.didAddArbitraryLog(sender: Sender(origin: self, localized: self), parentDogName: "Bella", newArbitraryLog: arbitraryLog)
            self.performSegue(withIdentifier: "unwindToLogsViewController", sender: self)
        }
        catch {
            ErrorProcessor.handleError(sender: Sender(origin: self, localized: self), error: error)
        }
    }
    
    @IBAction private func willCancel(_ sender: Any) {
        self.dismissKeyboard()
        self.performSegue(withIdentifier: "unwindToLogsViewController", sender: self)
    }
    
    @IBAction func didUpdateDatePicker(_ sender: Any) {
        self.dismissKeyboard()
    }
    
    
    
    //MARK: - Properties
    
    var lastArbitraryLogName: String? = nil
    
    var delegate: LogsAddArbitraryLogViewControllerDelegate! = nil
    
    //MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupToHideKeyboardOnTapOnView()
        
        view.bringSubviewToFront(cancelAddLogButton)
        
        logDisclaimer.frame.size = (logDisclaimer.text?.boundingFrom(font: logDisclaimer.font, width: logDisclaimer.frame.width))!
        
        logDisclaimer.constraints[0].isActive = false
        
        logName.text = lastArbitraryLogName
        logName.delegate = self
        logNote.delegate = self
        
        logDate.date = Date.roundDate(targetDate: Date(), roundingInterval: 60.0*5, roundingMethod: .up)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utils.presenter = self
    }

}
