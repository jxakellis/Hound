//
//  SecondViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 11/4/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

class DogsViewController: UIViewController, DogsAddDogViewControllerDelegate {
    
    //MARK: DogsAddDogViewControllerDelegate
    
    func didAddDog(addedDog: Dog) throws {
        //
    }
    

    @IBOutlet weak var addDog: UIButton!
    
    @IBAction func addDog(_ sender: Any) {
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addDogButtonConfig()
    }
    
    func addDogButtonConfig(){
        addDog.layer.cornerRadius = 8.0
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dogAddDogViewController"{
            
        }
    }
    

}

