//
//  HomeMainScreenTableViewCellRequirementLog.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/26/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol HomeMainScreenTableViewCellRequirementLogDelegate {
    func didDisable(sender: Sender, dogName: String, requirementName: String)
    func didSnooze(sender: Sender, dogName: String, requirementName: String)
    func didReset(sender: Sender, dogName: String, requirementName: String)
    
}

class HomeMainScreenTableViewCellRequirementLog: UITableViewCell {
    
    var delegate: HomeMainScreenTableViewCellRequirementLogDelegate! = nil
    
    var status = false
    
    @IBOutlet weak var requirementName: UILabel!
    @IBOutlet weak var dogName: UILabel!
    
    @IBOutlet weak var disableText: UILabel!
    @IBOutlet weak var disableButton: ScaledButton!
    @IBOutlet weak var snoozeText: UILabel!
    @IBOutlet weak var snoozeButton: ScaledButton!
    @IBOutlet weak var resetText: UILabel!
    @IBOutlet weak var resetButton: ScaledButton!
    
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
    
    func toggleFade(newFadeStatus isFadingTo: Bool, animated: Bool, fadeCompletion: ((Bool) -> Void)? = nil){
        if isFadingTo == true{
            if animated == true{
                self.applyAlpha(newAlpha: 0)
            UIView.animate(withDuration: AnimationConstant.HomeLogStateAnimate.rawValue) {
                self.applyAlpha(newAlpha: 1)
            } completion: { (completed) in
                //completion
            }
            }
            else {
                self.applyAlpha(newAlpha: 1)
            }
        }
        else if isFadingTo == false{
            fatalError("HomeMainScreenTableViewCellRequirementLog toggleFade(newFadeStatus: True, etc...) code current broken, don't use")
            //something weird is happening with the cell, when trying to fade buttons away when preparing for a new cell, even the direct below statement doesn't work, it won't change the button opacities at all. I even made it so that the cells are always log state and doesn't change so they stay loaded when I hit my green/blue checkmark but still nothing works. I tried DispatchQueue.Main but nothing seems to allow for change. I disabled reloadTable aswell so these cells stayed loaded even when they should have been replaced with the coundown display cells but still I could not change opacity. Investigate, the problem most likely does not lie within this tableViewCell class but rather the parent tableView class, possible due to something with memory and loading where the cell is no longer loaded/modifyable/something even though I can still reference it.
            self.applyAlpha(newAlpha: 0)
            if animated == true {
                    UIView.animate(withDuration: AnimationConstant.HomeLogStateAnimate.rawValue) {
                        let nano = Calendar(identifier: .gregorian).component(.nanosecond, from: Date())
                        print("in actual cell, started \(nano)")
                        self.applyAlpha(newAlpha: 0)
                    } completion: { (completed) in
                        let nano = Calendar(identifier: .gregorian).component(.nanosecond, from: Date())
                        print("in actual cell, completed \(nano)")
                        if fadeCompletion != nil {
                            fadeCompletion!(completed)
                        }
                    }
            }
            else if animated == false {
                self.applyAlpha(newAlpha: 0)
            }
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        requirementName.adjustsFontSizeToFitWidth = true
        dogName.adjustsFontSizeToFitWidth = true
        
       // self.applyAlpha(newAlpha: 0)
        //self.toggleFade(newFadeStatus: true, animated: true)
        
       // self.contentView.bringSubviewToFront(disableText)
       // self.contentView.bringSubviewToFront(snoozeText)
       // self.contentView.bringSubviewToFront(resetText)
    }
    
    ///Applys alpha value to all buttons and their labels in the cell.
    private func applyAlpha(newAlpha: CGFloat){
        disableText.alpha = newAlpha
        disableButton.alpha = newAlpha
        snoozeText.alpha = newAlpha
        snoozeButton.alpha = newAlpha
        resetText.alpha = newAlpha
        resetButton.alpha = newAlpha
    }

}
