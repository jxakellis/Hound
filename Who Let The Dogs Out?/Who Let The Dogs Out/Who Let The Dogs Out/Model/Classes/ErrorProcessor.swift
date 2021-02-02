//
//  ErrorProcessor.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/1/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit


class ErrorProcessor: UIViewController, AlertError {
    
    static func handleError(error: Error, classCalledFrom: UIViewController) -> Bool {
        //print(NSStringFromClass(classCalledFrom.classForCoder))
        return false
    }
    
    private func handleDogSpecificationError(error: Error) -> Bool{
        return false
    }
    
    private func handleDogManagerError(error: Error) -> Bool{
        return false
    }
    
    private func handleDogRequirementError(error: Error) -> Bool{
        return false
    }
    
    private func handleDogRequirementManagerError(error: Error) -> Bool{
        return false
    }
}
 
