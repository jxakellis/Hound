//
//  UIApplicationExtension.swift
//  Hound
//
//  Created by Jonathan Xakellis on 6/3/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

extension UIApplication {
    
    /// Special keyWindow
    static var keyWindow: UIWindow? {
        // Get connected scenes
        return UIApplication.shared.connectedScenes
        // Keep only active scenes, onscreen and visible to the user
            .filter { $0.activationState == .foregroundActive }
        // Keep only the first `UIWindowScene`
            .first(where: { $0 is UIWindowScene })
        // Get its associated windows
            .flatMap({ $0 as? UIWindowScene })?.windows
        // Finally, keep only the key window
            .first(where: \.isKeyWindow)
    }
    
    static var previousAppBuild: Int?
    
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
    
    static var appBuild: Int {
        
        return Int((Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String) ?? "1228") ?? 1228
    }
}
