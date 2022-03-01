//
//  ScaledUIButton.swift
//  Hound
//
//  Created by Jonathan Xakellis on 8/30/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class ScaledUIButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.scaleSymbolPontSize()
    }

    private func scaleSymbolPontSize() {
        var smallestDimension: CGFloat {
            if self.frame.width <= self.frame.height {
                return self.frame.width
            }
            else {
                return self.frame.height
            }
        }

        if currentImage != nil && currentImage!.isSymbolImage == true {
            DispatchQueue.main.async {
                super.setImage(self.currentImage?.applyingSymbolConfiguration(UIImage.SymbolConfiguration.init(pointSize: smallestDimension)), for: .normal)
            }
        }

    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.scaleSymbolPontSize()
    }

    override func setImage(_ image: UIImage?, for state: UIControl.State) {
        super.setImage(image, for: state)
        self.scaleSymbolPontSize()
    }

}
