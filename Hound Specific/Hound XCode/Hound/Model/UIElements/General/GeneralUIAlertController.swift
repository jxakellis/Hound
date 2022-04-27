//
//  CustomClasses.swift
//  Hound
//
//  Created by Jonathan Xakellis on 4/15/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import MediaPlayer
import UIKit

class GeneralUIAlertController: UIAlertController {
    
    /// This is simply a tag attached to the alertController. This helps keep track of different types alert controller and remove duplicates
    var tag: Int = 0
    
    override func viewDidDisappear(_ animated: Bool) {
        AlertManager.shared.alertDidComplete()
    }
    
}
