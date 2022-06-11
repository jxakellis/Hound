//
//  File.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/11/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

extension UISegmentedControl {
    /// Assumes the segmented control is configured for interfaceStyle selection (0: light, 1: dark, 2: unspecified). Using the selectedSegmentIndex, queries the server to update the interfaceStyle UserConfiguration. If successful, then changes UI to new interface style and saves new UserConfiguration value. If unsuccessful, reverts the selectedSegmentIndex to the position before the change, doesn't change the UI interface style, and doesn't save the new UserConfiguration value
    func updateInterfaceStyle() {
        
        var convertedInterfaceStyleRawValue: Int?
        let beforeUpdateInterfaceStyle = UserConfiguration.interfaceStyle
        
        switch self.selectedSegmentIndex {
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
                    self.selectedSegmentIndex = 2
                    // light
                case 1:
                    self.selectedSegmentIndex = 0
                    // dark
                case 2:
                    self.selectedSegmentIndex = 1
                default:
                    self.selectedSegmentIndex = 2
                }
            }
        }
    }
}
