//
//  Design Constant.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/26/22.
//  Copyright © 2022 Jonathan Xakellis. All rights reserved.
//

import UIKit

enum DesignConstant {
    static let largeButtonFont = UIFont.systemFont(ofSize: 30.0, weight: .semibold)
    static let largeButtonCornerStyle = UIButton.Configuration.CornerStyle.large
    static let largeButtonForegroundColor = UIColor.white
    static let largeButtonBackgroundColor = UIColor.systemBlue
    /// Configures a buttons values to the standard defaults defined here
    static func standardizeLargeButton(forButton button: UIButton) {
        button.setAttributedTitle(NSAttributedString(string: button.configuration?.title ?? "", attributes: [.font: largeButtonFont]), for: .normal)
        button.configuration?.cornerStyle = .large
        button.configuration?.baseForegroundColor = largeButtonForegroundColor
        button.configuration?.baseBackgroundColor = largeButtonBackgroundColor
    }
}
