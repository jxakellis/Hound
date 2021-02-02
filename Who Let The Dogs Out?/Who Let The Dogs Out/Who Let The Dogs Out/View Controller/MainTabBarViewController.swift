//
//  MainTabBarViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 2/1/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

class MainTabBarViewController: UITabBarController {

    var masterDogList: DogManager = DogManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //MOVE DEFAULT DOGS TO HERE, for example if a one dog and one requirement is added for the user to start off with, it should be up here, otherwise there is a potential disconnect as it shows the dog/requirement in subview / sub VCs but this master list does not have the data, should be top down inside of inserted half way in
        let dogsViewController = self.viewControllers![1] as! DogsViewController
        dogsViewController.dogManager = masterDogList
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
