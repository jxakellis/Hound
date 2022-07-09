//
//  View Tag Constant.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/6/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum ViewTagConstant {
    // reserve 0 through 9999 for use within app. it will never reach anywhere near that level but it costs nothing to reserver some tags.
    
    static let placeholderForBorderedUILabel = 1000000001
    static let placeholderForScaledUILabel = 1000000002
    static let placeholderForUITextView = 1000000003
    static let weekdayEnabled = 1000000004
    static let weekdayDisabled = 1000000005
    static let loadingViewController = 1000000006
    static let serverRelatedViewController = 1000000007
}

enum FontConstant {
    static let logCellFontSize = 13.0
    static let filterByDogFont = UIFont.systemFont(ofSize: 20, weight: .semibold)
    static let filterByLogFont = UIFont.systemFont(ofSize: 15, weight: .regular)
}

enum AnimationConstant {
    static let largeButtonShow = 0.3
    static let largeButtonHide = 0.15
    static let weekdayButton = 0.12
    static let willToggleDropDownSelection = 0.12
}
