//
//  DogsMainScreenTableViewCellDogDescription.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 1/11/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsMainScreenTableViewCellDogDisplayDelegate{
    func didToggleDogSwitch(sender: Sender, dogName: String, isEnabled: Bool)
}

class DogsMainScreenTableViewCellDogDisplay: UITableViewCell {
    
    //MARK: IB
    
    @IBOutlet weak var dogName: UILabel!
    
    @IBOutlet weak var dogToggleSwitch: UISwitch!
    
    //Occurs when the on off switch is toggled
    @IBAction func didToggleDogSwitch(_ sender: Any) {
        dog.setEnable(newEnableStatus: dogToggleSwitch.isOn)
       delegate.didToggleDogSwitch(sender: Sender(origin: self, localized: self), dogName: dog.dogTraits.dogName, isEnabled: self.dog.getEnable())
    }
    
    //MARK: Properties
    
    var dog: Dog = Dog()
    
    var delegate: DogsMainScreenTableViewCellDogDisplayDelegate! = nil
    
    //MARK: Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.dogName.adjustsFontSizeToFitWidth = true
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    //Function used externally to setup dog
    func setup(dogPassed: Dog){
        dog = dogPassed
        self.dogName.text = dogPassed.dogTraits.dogName
        self.dogToggleSwitch.isOn = dogPassed.getEnable()
    }
    
}
