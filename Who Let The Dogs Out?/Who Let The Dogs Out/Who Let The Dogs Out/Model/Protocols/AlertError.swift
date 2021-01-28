//
//  AlertError.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 1/28/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol AlertError: UIViewController {
    //If an error is found, call this method to display an alert controller popup stating the error to the user
    
    func alertForError(message: String)
}

extension AlertError{
    //If an error is found, call this method to display an alert controller popup stating the error to the user
    func alertForError(message: String){
        let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(alertAction)
        present(alertController, animated: true, completion: nil)
    }
}
