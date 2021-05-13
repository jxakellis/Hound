//
//  AlertPresenter.swift
//  AlertQueue-Example
//
//  Created by William Boles on 26/05/2019.
//  Copyright © 2019 William Boles. All rights reserved.
//
//  Modified by Jonathan Xakellis on 2/5/21.
//

import UIKit

class AlertPresenter: NSObject, NSCoding{
    
    //MARK: - NSCoding
    required init?(coder aDecoder: NSCoder) {
        alertQueue = aDecoder.decodeObject(forKey: "alertQueue") as! Queue<GeneralAlertController>
        locked = aDecoder.decodeBool(forKey: "locked")
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(alertQueue, forKey: "alertQueue")
        aCoder.encode(locked, forKey: "locked")
    }
    
    override init(){
        super.init()
    }
    
    private var alertQueue = Queue<GeneralAlertController>()
    private var locked = false
    private var halted = false
    var currentPresentation: GeneralAlertController?
    
    static var shared = AlertPresenter()
    
    // MARK: - Present
    
    func enqueueAlertForPresentation(_ alertController: GeneralAlertController) {
        
        /*
         if let popoverController = alertController.popoverPresentationController {
             popoverController.sourceView = Utils.presenter.view
             popoverController.sourceRect = Utils.presenter.view.bounds
           popoverController.permittedArrowDirections = []
         }
         */
        
        
        alertQueue.enqueue(alertController)
        
        showNextAlert()
    }
    
    private func showNextAlert() {
        guard halted == false else {
            return
        }
        
        if Utils.presenter == nil{
            func waitLoop(){
                print("waitLoop checker")
                if Utils.presenter == nil {
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                        waitLoop()
                    }
                }
                else{
                    showNextAlert()
                }
                
            }
        }
        else {
            if alertQueue.queuePresent() && locked == false{
                locked = true
                currentPresentation = alertQueue.elements.first
                Utils.presenter!.present(currentPresentation!, animated: true)
            }
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
        //DogManagerEfficencyImprovement let sudoDogManager = dogManager.copy() as! DogManager
        if currentPresentation == nil {
            for d in dogManager.dogs{
                for r in d.dogRequirments.requirements{
                    if r.isPresentationHandled == true {
                        TimingManager.willShowTimer(dogName: d.dogTraits.dogName, requirement: r)
                    }
                }
            }
        }
        halted = false
        showNextAlert()
    }
}

