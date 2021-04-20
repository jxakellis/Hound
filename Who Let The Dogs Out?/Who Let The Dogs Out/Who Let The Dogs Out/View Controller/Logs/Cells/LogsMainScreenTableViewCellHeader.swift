//
//  LogsMainScreenTableViewCellHeader.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 4/19/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class LogsMainScreenTableViewCellHeader: UITableViewCell {
    
    @IBOutlet weak var header: CustomLabel!
    
    //MARK: Properties
    
    var dateSource: Date! = nil
    
    //MARK: Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    /*
     //https://nsdateformatter.com/ "EEEE, MMMM d, yyyy"
     //DateFormatter().dateStyle = "full"
     //DateFormatter().timeStyle = "none"
     //https://stackoverflow.com/questions/24100855/set-a-datestyle-in-swift
     */
    
    func setup(dateSource: Date?){
        self.dateSource = dateSource
        
        if dateSource == nil {
            header.text = "No Logs Recorded"
        }
        else {
            let currentYearComponent = Calendar.current.component(.year, from: Date())
            let dateSourceYearComponent = Calendar.current.component(.year, from: dateSource!)
            
            //today
            if Calendar.current.isDateInToday(dateSource!){
                header.text = "Today"
            }
            //yesterday
            else if Calendar.current.isDateInYesterday(dateSource!){
                header.text = "Yesterday"
            }
            //this year
            else if currentYearComponent == dateSourceYearComponent{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEEE, MMMM d", options: 0, locale: Calendar.current.locale)
                header.text = dateFormatter.string(from: dateSource!)
            }
            //previous year or even older
            else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEEE, MMMM d, yyyy", options: 0, locale: Calendar.current.locale)
                header.text = dateFormatter.string(from: dateSource!)
            }
        }
    }
    
}
