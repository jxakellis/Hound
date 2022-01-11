//
//  ViewModel.swift
//  WeatherApp
//
//  Created by Nyisztor, Karoly on 5/24/18.
//  Copyright © 2018 Nyisztor, Karoly. All rights reserved.
//

import Foundation

class ViewModel {
    private var myModel = Model<Date>()
    
    func addEntry() {
        myModel.insert(Date())
    }
    
    var count: Int {
        return myModel.count
    }
    
    func removeEntry(at index: Int) {
        myModel.remove(at: index)
    }
    
    subscript(index: Int) -> String? {
        guard let date = myModel[index] else {
            return nil
        }
        return date.description
    }
}

