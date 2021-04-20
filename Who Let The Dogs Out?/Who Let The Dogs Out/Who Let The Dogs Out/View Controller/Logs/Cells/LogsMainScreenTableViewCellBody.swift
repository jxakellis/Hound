//
//  LogsMainScreenTableViewCellBody.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 4/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class LogsMainScreenTableViewCellBody: UITableViewCell {

    
    //MARK: IB
    
    @IBOutlet weak var dogName: CustomLabel!
    @IBOutlet weak var requirementName: CustomLabel!
    @IBOutlet weak var dateDescription: CustomLabel!
    
    //MARK: Properties
    
    var parentDogName: String! = nil
    var requirementSource: Requirement! = nil
    var dateSource: Date! = nil
    
    //MARK: Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup(date: Date, parentDogName: String, requirement: Requirement){
        self.dateSource = date
        self.requirementSource = requirement
        self.parentDogName = parentDogName
        
        self.dogName.text = parentDogName
        self.requirementName.text = requirement.requirementName
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "h:mm a", options: 0, locale: Calendar.current.locale)
        dateDescription.text = dateFormatter.string(from: date)
        
        dogName.frame = CGRect(origin: dogName.frame.origin,
                               size: dogName.text!.withBoundedWidth(font: dogName.font, height: dogName.frame.height))
        requirementName.frame = CGRect(origin: requirementName.frame.origin,
                                            size: requirementName.text!.withBoundedWidth(font: requirementName.font, height: requirementName.frame.height))
        
    }

    
}
