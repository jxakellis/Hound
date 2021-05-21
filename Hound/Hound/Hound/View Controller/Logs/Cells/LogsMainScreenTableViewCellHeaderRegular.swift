//
//  LogsMainScreenTableViewCellHeaderRegular.swift
//  Hound
//
//  Created by Jonathan Xakellis on 5/20/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class LogsMainScreenTableViewCellHeaderRegular: UITableViewCell {

    @IBOutlet private weak var header: CustomLabel!
    
    //MARK: - Properties
    
    private var logSource: KnownLog? = nil
    
    //MARK: - Main
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /*
     //https://nsdateformatter.com/ "EEEE, MMMM d, yyyy"
     //DateFormatter().dateStyle = "full"
     //DateFormatter().timeStyle = "none"
     //https://stackoverflow.com/questions/24100855/set-a-datestyle-in-swift
     */
    
    func setup(log logSource: KnownLog?){
        self.logSource = logSource
                if logSource == nil {
            header.text = "No Logs Recorded"
        }
        else {
            let dateSource = logSource!.date
            
            let currentYearComponent = Calendar.current.component(.year, from: Date())
            let dateSourceYearComponent = Calendar.current.component(.year, from: dateSource)
            
            //today
            if Calendar.current.isDateInToday(dateSource){
                header.text = "Today"
            }
            //yesterday
            else if Calendar.current.isDateInYesterday(dateSource){
                header.text = "Yesterday"
            }
            //this year
            else if currentYearComponent == dateSourceYearComponent{
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEEE, MMMM d", options: 0, locale: Calendar.current.locale)
                header.text = dateFormatter.string(from: dateSource)
            }
            //previous year or even older
            else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = DateFormatter.dateFormat(fromTemplate: "EEEE, MMMM d, yyyy", options: 0, locale: Calendar.current.locale)
                header.text = dateFormatter.string(from: dateSource)
            }
        }
    }

}
