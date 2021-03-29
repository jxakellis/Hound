//
//  SecondViewController.swift
//  Who Let The Dogs Out
//
//  Created by Jonathan Xakellis on 11/4/20.
//  Copyright © 2020 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol DogsViewControllerDelegate {
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager)
}

class DogsViewController: UIViewController, DogManagerControlFlowProtocol, DogsAddDogViewControllerDelegate, DogsMainScreenTableViewControllerDelegate, DogsUpdateRequirementViewControllerDelegate{
    
    //MARK: DogsUpdateRequirementViewControllerDelegate
    
    func didUpdateRequirement(sender: Sender, parentDogName: String, formerName: String, updatedRequirement: Requirement) throws {
        let sudoDogManager = getDogManager()
        
        try sudoDogManager.findDog(dogName: parentDogName).dogRequirments.changeRequirement(requirementToBeChanged: formerName, newRequirement: updatedRequirement)
        
        setDogManager(sender: sender, newDogManager: sudoDogManager)
    }
    
    //MARK: DogsMainScreenTableViewControllerDelegate
    
    ///If a dog was clicked on in DogsMainScreenTableViewController, this function is called with a delegate and allows for the updating of the dogs information
    func didSelectDog(indexPathSection dogIndex: Int) {
        
        willOpenDog(dogToBeOpened: getDogManager().dogs[dogIndex])
        
    }
    
    private var selectedTargetRequirement: Requirement!
    private var selectedParentDogName: String!
    ///If a requirement was clicked on in DogsMainScreenTableViewController, this function is called with a delegate and allows for the updating of the requirements information
    func didSelectRequirement(indexPathSection dogIndex: Int, indexPathRow requirementIndex: Int) {
        
        selectedTargetRequirement = getDogManager().dogs[dogIndex].dogRequirments.requirements[requirementIndex]
        try! selectedParentDogName = getDogManager().dogs[dogIndex].dogSpecifications.getDogSpecification(key: "name")
        
        self.performSegue(withIdentifier: "dogsUpdateRequirementViewController", sender: DogsMainScreenTableViewController())
        
    }
    
    //MARK: DogManagerControlFlowProtocol
    
    ///If the dog manager was updated in DogsMainScreenTableViewController, this function is called to reflect that change here with this dogManager
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager) {
        setDogManager(sender: sender, newDogManager: newDogManager)
    }
    
    //MARK: DogsAddDogViewControllerDelegate
    
    ///If a dog was added by the subview, this function is called with a delegate and is incorporated into the dog manager here
    func didAddDog(sender: Sender, newDog: Dog) throws {
        
        //This makes it so when a dog is added all of its requirements start counting down at the same time (b/c same last execution) instead counting down from when the requirement was added to the dog.
        for requirementIndex in 0..<newDog.dogRequirments.requirements.count{
            newDog.dogRequirments.requirements[requirementIndex].changeExecutionBasis(newExecutionBasis: Date())
        }
        
        var sudoDogManager = getDogManager()
        try sudoDogManager.addDog(dogAdded: newDog)
        setDogManager(sender: sender, newDogManager: sudoDogManager)
        //try delegate.didAddDog(dogAdded: addedDog)
    }
    
    ///If a dog was updated, its former name (as its name could have been changed) and new dog instance is passed here, matching old dog is found and replaced with new
    func didUpdateDog(sender: Sender, formerName: String, updatedDog: Dog) throws {
        var sudoDogManager = getDogManager()
        try sudoDogManager.changeDog(dogNameToBeChanged: formerName, newDog: updatedDog)
        setDogManager(sender: sender, newDogManager: sudoDogManager)
    }
    
    //MARK: IB
    
    @IBOutlet weak var willAddButton: UIButton!
    
    @IBOutlet weak var willAddButtonBackground: UIButton!
    
    
    //MARK: Dog Manager
    
    private var dogManager = DogManager()
    
    func getDogManager() -> DogManager {
        return dogManager.copy() as! DogManager
    }
    
    func setDogManager(sender: Sender, newDogManager: DogManager) {
        dogManager = newDogManager.copy() as! DogManager
        
        //possible senders
        //DogsMainScreenTableViewController
        //DogsAddDogViewController
        //MainTabBarViewController
        
        if !(sender.localized is DogsMainScreenTableViewController) {
            dogsMainScreenTableViewController.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
        }
        
        if !(sender.localized is MainTabBarViewController)  {
            delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), newDogManager: getDogManager())
        }
        
    }
    
    //Updates different visual aspects to reflect data change of dogManager
    func updateDogManagerDependents(){
        //
    }
    
    //MARK: Properties
    
    var delegate: DogsViewControllerDelegate! = nil
    
    var dogsMainScreenTableViewController = DogsMainScreenTableViewController()
    
    var dogsAddDogViewController = DogsAddDogViewController()
    
    var dogsUpdateRequirementViewController = DogsUpdateRequirementViewController()
    
    //MARK: Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.bringSubviewToFront(willAddButtonBackground)
        self.view.bringSubviewToFront(willAddButton)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.changeAddStatus(newAddStatus: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    //MARK: Navigation To Dog Addition and Modification
    
    ///Opens the dogsAddDogViewController, if a dog is passed (which is required) then instead of opening a fresh add dog page, opens up the corrosponding one for the dog
    private func willOpenDog(dogToBeOpened: Dog? = nil ){
        
        self.performSegue(withIdentifier: "dogsAddDogViewController", sender: self)
        
        ///Is opening a dog
        if dogToBeOpened != nil {
        //Conversion of "DogsAddDogViewController" to update mode
        dogsAddDogViewController.isUpdating = true
        dogsAddDogViewController.targetDog = dogToBeOpened!
        dogsAddDogViewController.willInitalize()
        
        dogsAddDogViewController.addDogButton.setTitle("Update Dog", for: .normal)
        }
        
    }
    
    @objc private func willOpenDog(sender: UIButton) {
        print("sender tag \(sender.tag)")
        if sender.tag == 0 {
            self.willOpenDog(dogToBeOpened: nil)
        }
        else {
            self.willOpenDog(dogToBeOpened: getDogManager().dogs[sender.tag-1])
        }
    }
    
    //MARK: Programmically Added Add Requirement To Dog / Add Dog Buttons
    
    private var addStatus: Bool = false
    private var addButtons: [ScaledButton] = []
    private var addButtonsBackground: [ScaledButton] = []
    
    ///Changes the status of the subAddButtons which navigate to add a dog, add a requirement for "DOG NAME", add a requirement for "DOG NAME 2" etc, from present and active to hidden, includes animation
    private func changeAddStatus(newAddStatus: Bool){
        
        if newAddStatus == true{
            //Slight correction with last () as even with the correct corrindates for aligned trailing for some reason the the new subbuttons slightly bluge out when they should be conceiled by the WillAddButton.
            let originXWithAlignedTrailing: CGFloat = (willAddButton.frame.origin.x+willAddButton.frame.width)-subButtonSize-(willAddButton.frame.size.width*0.035)
            
            let willAddDogButton = ScaledButton(frame: CGRect(origin: CGPoint(x: originXWithAlignedTrailing, y: willAddButton.frame.origin.y - 10 - subButtonSize), size: CGSize(width: subButtonSize, height: subButtonSize)))
            //TRADITIONAL willAddDogButton.setImage(UIImage(systemName: "plus.circle.fill")!, for: .normal)
            willAddDogButton.setImage(UIImage(systemName: "plus.circle")!, for: .normal)
            willAddDogButton.tintColor = .link
            willAddDogButton.tag = 0
            willAddDogButton.addTarget(self, action: #selector(willOpenDog(sender:)), for: .touchUpInside)
            
            let willAddDogButtonBackground = ScaledButton(frame: CGRect(origin: CGPoint(x: originXWithAlignedTrailing, y: willAddButton.frame.origin.y - 10 - subButtonSize), size: CGSize(width: subButtonSize, height: subButtonSize)))
            //TRADITIONAL willAddDogButtonBackground.setImage(UIImage(systemName: "plus.circle"), for: .normal)
            willAddDogButtonBackground.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
            willAddDogButtonBackground.tintColor = .systemBackground
            willAddDogButtonBackground.isUserInteractionEnabled = false
            
            addButtons.append(willAddDogButton)
            addButtonsBackground.append(willAddDogButtonBackground)
            
            for dogIndex in 0..<getDogManager().dogs.count{
                guard maximumSubButtonCount > addButtons.count else {
                    break
                }
                
                let willAddRequirementButton = ScaledButton(frame: CGRect(origin: CGPoint(x: addButtons.last!.frame.origin.x, y: addButtons.last!.frame.origin.y - 10 - subButtonSize), size: CGSize(width: subButtonSize, height: subButtonSize)))
                willAddRequirementButton.setImage(UIImage(systemName: "plus.circle.fill")!, for: .normal)
                willAddRequirementButton.tintColor = .link
                willAddRequirementButton.tag = dogIndex+1
                willAddRequirementButton.addTarget(self, action: #selector(willOpenDog(sender:)), for: .touchUpInside)
                
                let willAddRequirementButtonBackground = ScaledButton(frame: CGRect(origin: CGPoint(x: addButtons.last!.frame.origin.x, y: addButtons.last!.frame.origin.y - 10 - subButtonSize), size: CGSize(width: subButtonSize, height: subButtonSize)))
                willAddRequirementButtonBackground.setImage(UIImage(systemName: "plus.circle")!, for: .normal)
                willAddRequirementButtonBackground.tintColor = .systemBackground
                willAddRequirementButtonBackground.isUserInteractionEnabled = false
                
                addButtons.append(willAddRequirementButton)
                addButtonsBackground.append(willAddRequirementButtonBackground)
                
            }
            for buttonIndex in 0..<addButtons.count{
                let button = addButtons[buttonIndex]
                let buttonBackground = addButtonsBackground[buttonIndex]
                
                let buttonOrigin = button.frame.origin
                
                let originYWithAlignedMiddle = willAddButton.frame.midY - (button.frame.height/2)
                
                button.frame.origin = CGPoint(x: button.frame.origin.x, y: originYWithAlignedMiddle)
                buttonBackground.frame.origin = button.frame.origin
                
                //button.alpha = 0
                view.addSubview(buttonBackground)
                view.addSubview(button)
                UIView.animate(withDuration: AnimationConstant.HomeLogStateAnimate.rawValue) {
                    button.frame.origin = buttonOrigin
                    buttonBackground.frame.origin = buttonOrigin
                    //button.alpha = 1
                } completion: { (completed) in
                    //
                }

            }
            view.bringSubviewToFront(willAddButtonBackground)
            view.bringSubviewToFront(willAddButton)
            
        }
        else if newAddStatus == false{
            for buttonIndex in 0..<addButtons.count{
                let button = addButtons[buttonIndex]
                let buttonBackground = addButtonsBackground[buttonIndex]
                //button.alpha = 1
                let originYWithAlignedMiddle = willAddButton.frame.midY - (button.frame.height/2)
                
                UIView.animate(withDuration: AnimationConstant.HomeLogStateAnimate.rawValue) {
                    
                    
                    button.frame.origin = CGPoint(x: button.frame.origin.x, y: originYWithAlignedMiddle)
                    buttonBackground.frame.origin = CGPoint(x: button.frame.origin.x, y: originYWithAlignedMiddle)
                    //button.alpha = 0
                } completion: { (completed) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + AnimationConstant.HomeLogStateDisappearDelay.rawValue) {
                        button.isHidden = true
                        button.removeFromSuperview()
                        buttonBackground.isHidden = true
                        buttonBackground.removeFromSuperview()
                    }
                }

            }
            addButtons.removeAll()
            addButtonsBackground.removeAll()
        }
        addStatus = newAddStatus
    }
    
    @IBAction func willAddButton(_ sender: Any) {
        self.changeAddStatus(newAddStatus: !addStatus)
        //performSegue(withIdentifier: "dogsAddDogViewController", sender: self)
    }
    
    ///The size of the subAddButtons in relation to the willAddButtomn
    private var subButtonSize: CGFloat {
        let multiplier: CGFloat = 0.65
        if willAddButton.frame.size.width <= willAddButton.frame.size.height{
            return willAddButton.frame.size.width * multiplier
        }
        else {
            return willAddButton.frame.size.height * multiplier
        }
    }
    @IBOutlet private weak var thinBlackLine: UIImageView!
    
    ///Calculates total Y space available, from the botton of the thinBlackLine below the pageTitle to the top of the willAddButton
    private var subButtonTotalAvailableYSpace: CGFloat {
        return willAddButton.frame.origin.y - (thinBlackLine.frame.origin.y + thinBlackLine.frame.height)
    }
    
    ///Uses subButtonSize and subButtonTotalAvailableYSpace to figure out how many buttons can fit, rounds down, so if 2.9999 can fit then only 2 will as not enough space for third
    private var maximumSubButtonCount: Int {
        return Int(subButtonTotalAvailableYSpace / (subButtonSize + 10).rounded(.down))
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "dogsAddDogViewController"{
            dogsAddDogViewController = segue.destination as! DogsAddDogViewController
            dogsAddDogViewController.modalPresentationStyle = .fullScreen
            dogsAddDogViewController.delegate = self
        }
        if segue.identifier == "dogsMainScreenTableViewController" {
            dogsMainScreenTableViewController = segue.destination as! DogsMainScreenTableViewController
            dogsMainScreenTableViewController.delegate = self
        }
        if segue.identifier == "dogsUpdateRequirementViewController" {
            dogsUpdateRequirementViewController = segue.destination as! DogsUpdateRequirementViewController
            dogsUpdateRequirementViewController.targetRequirement = selectedTargetRequirement
            dogsUpdateRequirementViewController.parentDogName = selectedParentDogName
            dogsUpdateRequirementViewController.modalPresentationStyle = .fullScreen
            dogsUpdateRequirementViewController.delegate = self
        }
    }
    
    
}

