//
//  View Tag Constant.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/6/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import Foundation

enum ViewTagConstant: Int {
    // reserve 0 through 9999 for use within app. it will never reach anywhere near that level but it costs nothing to reserver some tags.
    
    case placeholderForBorderedUILabel = 10001
    case placeholderForScaledUILabel = 10002
    case placeholderForUITextView = 10003
    case weekdayEnabled = 10004
    case weekdayDisabled = 10005
    case loadingViewController = 10006
    case serverRelatedViewController = 10007
}
