//
//  HomeMainScreenTableViewCellDogRequirementLog.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/26/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol HomeMainScreenTableViewCellDogRequirementLogDelegate {
    func didDisable(sender: Sender, dogName: String, requirementName: String)
    func didSnooze(sender: Sender, dogName: String, requirementName: String)
    func didReset(sender: Sender, dogName: String, requirementName: String)
    
}

class HomeMainScreenTableViewCellDogRequirementLog: UITableViewCell {
    
    var delegate: HomeMainScreenTableViewCellDogRequirementLogDelegate! = nil
    
    @IBOutlet weak var requirementName: UILabel!
    @IBOutlet weak var dogName: UILabel!
    
    @IBOutlet weak var disableText: UILabel!
    @IBOutlet weak var snoozeText: UILabel!
    @IBOutlet weak var resetText: UILabel!
    
    @IBAction func didDisable(_ sender: Any) {
        delegate.didDisable(sender: Sender(origin: self, localized: self), dogName: dogName.text!, requirementName: requirementName.text!)
    }
    @IBAction func didSnooze(_ sender: Any) {
        delegate.didSnooze(sender: Sender(origin: self, localized: self), dogName: dogName.text!, requirementName: requirementName.text!)
    }
    @IBAction func didReset(_ sender: Any) {
        delegate.didReset(sender: Sender(origin: self, localized: self), dogName: dogName.text!, requirementName: requirementName.text!)
    }
    
    func setup(parentDogName: String, requirementName: String){
        self.requirementName.text = requirementName
        self.dogName.text = parentDogName
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        requirementName.adjustsFontSizeToFitWidth = true
        dogName.adjustsFontSizeToFitWidth = true
        
       // self.contentView.bringSubviewToFront(disableText)
       // self.contentView.bringSubviewToFront(snoozeText)
       // self.contentView.bringSubviewToFront(resetText)
    }

}
