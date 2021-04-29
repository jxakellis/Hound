//
//  DogsNavigationViewController.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 4/15/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsNavigationViewControllerDelegate{
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager)
}

class DogsNavigationViewController: UINavigationController, DogsViewControllerDelegate {
    
    //MARK: - DogsViewControllerDelegate
    
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager) {
        passThroughDelegate.didUpdateDogManager(sender: sender, newDogManager: newDogManager)
    }
    
    //MARK: - Properties
    
    var passThroughDelegate: DogsNavigationViewControllerDelegate! = nil
    
    var dogsViewController: DogsViewController!
    
    //MARK: - Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dogsViewController = self.viewControllers[0] as? DogsViewController
        dogsViewController.delegate = self
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
