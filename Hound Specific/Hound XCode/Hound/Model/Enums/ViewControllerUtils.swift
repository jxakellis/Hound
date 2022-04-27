//
//  ViewControllerUtils.swift
//  Hound
//
//  Created by Jonathan Xakellis on 2/10/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum ViewControllerUtils {
    
    static func performSegueOnceInWindowHierarchy(segueIdentifier: String, viewController: UIViewController) {
        
        waitLoop()
        
        func waitLoop () {
            if viewController.isViewLoaded && viewController.view.window != nil {
                viewController.performSegue(withIdentifier: segueIdentifier, sender: viewController)
            }
            else {
                AppDelegate.generalLogger.warning("waitloop for performSegueOnceInWindowHierarchy")
                DispatchQueue.main.asyncAfter(deadline: .now()+0.05) {
                    waitLoop()
                }
            }
        }
    }
    
    static func updateInterfaceStyle(forSegmentedControl segmentedControl: UISegmentedControl) {
        
        var convertedInterfaceStyleRawValue: Int?
        let beforeUpdateInterfaceStyle = UserConfiguration.interfaceStyle
        
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            convertedInterfaceStyleRawValue = 1
            UserConfiguration.interfaceStyle = .light
        case 1:
            convertedInterfaceStyleRawValue = 2
            UserConfiguration.interfaceStyle = .dark
        default:
            convertedInterfaceStyleRawValue = 0
            UserConfiguration.interfaceStyle = .unspecified
        }
        
        UIApplication.keyWindow?.overrideUserInterfaceStyle = UserConfiguration.interfaceStyle
        
        let body = [ServerDefaultKeys.interfaceStyle.rawValue: convertedInterfaceStyleRawValue!]
        UserRequest.update(invokeErrorManager: true, body: body) { requestWasSuccessful, _ in
            if requestWasSuccessful == false {
                // error, revert to previous
                UIApplication.keyWindow?.overrideUserInterfaceStyle = beforeUpdateInterfaceStyle
                UserConfiguration.interfaceStyle = beforeUpdateInterfaceStyle
                switch UserConfiguration.interfaceStyle.rawValue {
                    // system/unspecified
                case 0:
                    segmentedControl.selectedSegmentIndex = 2
                    // light
                case 1:
                    segmentedControl.selectedSegmentIndex = 0
                    // dark
                case 2:
                    segmentedControl.selectedSegmentIndex = 1
                default:
                    segmentedControl.selectedSegmentIndex = 2
                }
            }
        }
    }
    
}
