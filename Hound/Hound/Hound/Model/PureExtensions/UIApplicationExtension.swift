//
//  UIApplicationExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/3/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

extension UIApplication {
    
    static var previousAppBuild: Int = 0
    /*
     buildNumber=$(/usr/libexec/PlistBuddy -c "Print CFBundleVersion" "$INFOPLIST_FILE")
     buildNumber=$(($buildNumber + 1))
     /usr/libexec/PlistBuddy -c "Set :CFBundleVersion $buildNumber" "$INFOPLIST_FILE"

     */
    
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    static var appBuild: Int {
        
        return Int((Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String) ?? "1228") ?? 1228
    }
}
