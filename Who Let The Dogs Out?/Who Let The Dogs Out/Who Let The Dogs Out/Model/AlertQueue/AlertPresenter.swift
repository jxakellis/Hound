//
//  AlertPresenter.swift
//  AlertQueue-Example
//
//  Created by William Boles on 26/05/2019.
//  Copyright © 2019 William Boles. All rights reserved.
//
//  Modified by Jonathan Xakellis on 2/5/21.
//

import Foundation
import UIKit

class AlertPresenter{
    private var alertQueue = Queue<UIAlertController>()
    private var locked = false
    
    static let shared = AlertPresenter()
    
    // MARK: - Present
    
    func enqueueAlertForPresentation(_ alertController: UIAlertController) {
        alertQueue.enqueue(alertController)
        
        showNextAlert()
    }
    
    private func showNextAlert() {
        if alertQueue.queuePresent() && locked == false{
            locked = true
            print("showNextAlert elements count: \(alertQueue.elements.count)")
            Utils.presenter.present(alertQueue.dequeue()!, animated: true)
        }
    }
    
    func viewDidComplete() {
        locked = false
        showNextAlert()
    }
}

class CustomAlertController: UIAlertController {
    override func viewDidDisappear(_ animated: Bool) {
        AlertPresenter.shared.viewDidComplete()
    }
}
