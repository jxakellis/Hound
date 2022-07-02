//
//  View Tag Constant.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/6/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum ViewTagConstant: Int {
    // reserve 0 through 9999 for use within app. it will never reach anywhere near that level but it costs nothing to reserver some tags.
    
    case startOfReservedInts = 1000000000
    case placeholderForBorderedUILabel = 1000000001
    case placeholderForScaledUILabel = 1000000002
    case placeholderForUITextView = 1000000003
    case weekdayEnabled = 1000000004
    case weekdayDisabled = 1000000005
    case loadingViewController = 1000000006
    case serverRelatedViewController = 1000000007
}

enum FontConstant: Double {
    case logCellFontSize = 13.0
    static let filterByDogFont = UIFont.systemFont(ofSize: 20, weight: .semibold)
    static let filterByLogFont = UIFont.systemFont(ofSize: 15, weight: .regular)
}

enum AnimationConstant: Double {
    
    case largeButtonShow = 0.300001
    case largeButtonHide = 0.150001
    
    case weekdayButton = 0.120001
}
