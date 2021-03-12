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

class AlertPresenter: NSObject, NSCoding{
    
    //MARK: NSCoding
    required init?(coder aDecoder: NSCoder) {
        alertQueue = aDecoder.decodeObject(forKey: "alertQueue") as! Queue<CustomAlertController>
        locked = aDecoder.decodeBool(forKey: "locked")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(alertQueue, forKey: "alertQueue")
        aCoder.encode(locked, forKey: "locked")
    }
    
    override init(){
        super.init()
    }
    
    private var alertQueue = Queue<CustomAlertController>()
    private var locked = false
    private var halted = false
    var currentPresentation: CustomAlertController?
    
    static var shared = AlertPresenter()
    
    // MARK: - Present
    
    func enqueueAlertForPresentation(_ alertController: CustomAlertController) {
        alertQueue.enqueue(alertController)
        
        showNextAlert()
    }
    
    private func showNextAlert() {
        guard halted == false else {
            return
        }
        if alertQueue.queuePresent() && locked == false{
            locked = true
            currentPresentation = alertQueue.elements.first
            Utils.presenter.present(currentPresentation!, animated: true)
        }
    }
    
    func viewDidComplete() {
        locked = false
        currentPresentation = nil
        alertQueue.elements.removeFirst()
        showNextAlert()
    }
    
    func refresh(dogManager: DogManager){
        halted = true
        let sudoDogManager = dogManager.copy() as! DogManager
        if currentPresentation == nil {
            for d in sudoDogManager.dogs{
                for r in d.dogRequirments.requirements{
                    if r.isPresentationHandled == true {
                        try! TimingManager.willShowTimer(dogName: d.dogSpecifications.getDogSpecification(key: "name"), requirement: r)
                    }
                }
            }
        }
        halted = false
        showNextAlert()
    }
}

class CustomAlertController: UIAlertController {
    override func viewDidDisappear(_ animated: Bool) {
        AlertPresenter.shared.viewDidComplete()
    }
}
