//
//  AlertManager.swift
//  AlertQueue-Example
//
//  Created by William Boles on 26/05/2019.
//  Copyright © 2019 William Boles. All rights reserved.
//
//  Modified by Jonathan Xakellis on 2/5/21.
//

import UIKit

class AlertManager: NSObject {

    override init() {
        super.init()
    }

    private var alertQueue = Queue<GeneralUIAlertController>()
    private var locked = false
    private var halted = false
    private var currentAlertPresented: GeneralUIAlertController?

    static var shared = AlertManager()

    /// Default sender used to present, this is necessary if an alert to be shown is called from a non UIViewController class as that is not in the view heirarchy and physically cannot present a view, so this is used instead.
    static var globalPresenter: UIViewController?

    // MARK: -

    /// Function used to present alertController
    static func willShowAlert(title: String, message: String?) {
        var trimmedMessage: String? = message

        if message?.trimmingCharacters(in: .whitespaces) == ""{
            trimmedMessage = nil
        }

        let alertController = GeneralUIAlertController(
            title: title,
            message: trimmedMessage,
            preferredStyle: .alert)

        let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)

        alertController.addAction(alertAction)

        shared.enqueueAlertForPresentation(alertController)

    }

    // MARK: - Alert Queue Management

    func enqueueAlertForPresentation(_ alertController: GeneralUIAlertController) {
        guard alertController.preferredStyle == .alert else {
            fatalError("use enqueueActionSheetForPresentation instead")
        }

        alertQueue.enqueue(alertController)

        showNextAlert()
    }

    func enqueueActionSheetForPresentation(_ alertController: GeneralUIAlertController, sourceView: UIView, permittedArrowDirections: UIPopoverArrowDirection) {
        guard alertController.preferredStyle == .actionSheet else {
            fatalError("use enqueueAlertForPresentation instead")
        }

        switch UIDevice.current.userInterfaceIdiom {
        case .pad:
            alertController.popoverPresentationController?.sourceView = sourceView
            alertController.popoverPresentationController?.sourceRect = sourceView.bounds
            alertController.popoverPresentationController?.permittedArrowDirections = permittedArrowDirections
        default:
            break
        }

        alertQueue.enqueue(alertController)

        showNextAlert()
    }

    private func showNextAlert() {
        guard halted == false else {
            return
        }

        func waitLoop() {
            AppDelegate.generalLogger.notice("waitLoop due to being unable to present UIAlertController")
            if AlertManager.globalPresenter == nil {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                    waitLoop()
                }
            }
            else if AlertManager.globalPresenter!.isBeingDismissed {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
                    waitLoop()
                }
            }
            else {
                showNextAlert()
            }

        }
        if AlertManager.globalPresenter == nil {
            AppDelegate.generalLogger.notice("AlertManager.globalPresenter is nil, initiating waitLoop")
            waitLoop()

        }
        else if AlertManager.globalPresenter!.isBeingDismissed {
            AppDelegate.generalLogger.notice("AlertManager.globalPresenter is being dismissed, initiating waitLoop")
            waitLoop()
        }
        else {
            if alertQueue.queuePresent() && locked == false {
                locked = true
                currentAlertPresented = alertQueue.elements.first
                AlertManager.globalPresenter!.present(currentAlertPresented!, animated: true)
            }
        }

    }

    /// Invoke when the alert has finished being presented and a new alert is able to take its place
    func alertDidComplete() {
        locked = false
        currentAlertPresented = nil
        alertQueue.elements.removeFirst()
        showNextAlert()
    }

    func refreshAlerts(dogManager: DogManager) {
        halted = true
        if currentAlertPresented == nil {
            for d in dogManager.dogs {
                for r in d.dogReminders.reminders where r.isPresentationHandled == true {
                    TimingManager.willShowTimer(dogName: d.dogName, dogId: d.dogId, reminder: r)
                }
            }
        }
        halted = false
        showNextAlert()
    }
}

class Queue<Element>: NSObject {

    override init() {
        super.init()
    }

    var elements = [Element]()

    // MARK: - Operations

    func enqueue(_ element: Element) {
        elements.append(element)
    }

    func queuePresent() -> Bool {
        return !(elements.isEmpty)
    }

    func dequeue() -> Element? {
        guard !elements.isEmpty else {
            return nil
        }

        return elements.removeFirst()

    }
}
