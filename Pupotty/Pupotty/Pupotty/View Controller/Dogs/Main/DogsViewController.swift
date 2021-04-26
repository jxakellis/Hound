//
//  SecondViewController.swift
//  Pupotty
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
    
    func didRemoveRequirement(sender: Sender, parentDogName: String, removedRequirementName: String) {
        let sudoDogManager = getDogManager()
        
        try! sudoDogManager.findDog(dogName: parentDogName).dogRequirments.removeRequirement(requirementName: removedRequirementName)
        
        setDogManager(sender: sender, newDogManager: sudoDogManager)
    }
    
    //MARK: DogsMainScreenTableViewControllerDelegate
    
    ///If a dog was clicked on in DogsMainScreenTableViewController, this function is called with a delegate and allows for the updating of the dogs information
    func didSelectDog(indexPathSection dogIndex: Int) {
        
        willOpenDog(dogToBeOpened: getDogManager().dogs[dogIndex], isAddingRequirement: false)
        
    }
    
    private var selectedTargetRequirement: Requirement!
    private var selectedParentDogName: String!
    ///If a requirement was clicked on in DogsMainScreenTableViewController, this function is called with a delegate and allows for the updating of the requirements information
    func didSelectRequirement(indexPathSection dogIndex: Int, indexPathRow requirementIndex: Int) {
        
        selectedTargetRequirement = getDogManager().dogs[dogIndex].dogRequirments.requirements[requirementIndex]
        selectedParentDogName = getDogManager().dogs[dogIndex].dogTraits.dogName
        
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
            newDog.dogRequirments.requirements[requirementIndex].changeExecutionBasis(newExecutionBasis: Date(), shouldResetIntervalsElapsed: true)
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
    
    func didRemoveDog(sender: Sender, removedDogName: String) {
        var sudoDogManager = getDogManager()
        try! sudoDogManager.removeDog(name: removedDogName)
        setDogManager(sender: sender, newDogManager: sudoDogManager)
    }
    
    //MARK: DogManagerControlFlowProtocol
    
    private var dogManager = DogManager()
    
    func getDogManager() -> DogManager {
        //DogManagerEfficencyImprovement return dogManager.copy() as! DogManager
        return dogManager
    }
    
    func setDogManager(sender: Sender, newDogManager: DogManager) {
        //DogManagerEfficencyImprovement dogManager = newDogManager.copy() as! DogManager
        dogManager = newDogManager
        
        
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
    
    //MARK: IB
    
    @IBOutlet weak var willAddButton: UIButton!
    
    @IBOutlet weak var willAddButtonBackground: UIButton!
    
    @IBAction func willAddButton(_ sender: Any) {
            self.changeAddStatus(newAddStatus: !addStatus)
        }

    //MARK: Properties
    
    var delegate: DogsViewControllerDelegate! = nil
    
    var dogsMainScreenTableViewController = DogsMainScreenTableViewController()
    
    var dogsAddDogViewController = DogsAddDogViewController()
    
    var dogsUpdateRequirementViewController = DogsUpdateRequirementViewController()
    
    //MARK: Main
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dismissAddDogTap = UITapGestureRecognizer(target: self, action: #selector(toggleAddStatusToFalse))
        self.dismissAddDogTap = dismissAddDogTap
        
        let dimView = UIView(frame: self.view.frame)
        dimView.alpha = 0
        dimView.backgroundColor = UIColor.black
        dimScreenView = dimView
        dimScreenView.addGestureRecognizer(dismissAddDogTap)
        
        self.view.addSubview(dimView)
        
        self.view.bringSubviewToFront(willAddButtonBackground)
        self.view.bringSubviewToFront(willAddButton)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.changeAddStatus(newAddStatus: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utils.presenter = self
    }
    
    //MARK: Navigation To Dog Addition and Modification
    
    ///Opens the dogsAddDogViewController, if a dog is passed (which is required) then instead of opening a fresh add dog page, opens up the corrosponding one for the dog
    private func willOpenDog(dogToBeOpened: Dog? = nil, isAddingRequirement: Bool = false){
        
        self.performSegue(withIdentifier: "dogsAddDogViewController", sender: self)
        
        
        ///Is opening a dog
        if dogToBeOpened != nil {
        //Conversion of "DogsAddDogViewController" to update mode
            
        dogsAddDogViewController.isAddingRequirement = isAddingRequirement
        dogsAddDogViewController.isUpdating = true
        dogsAddDogViewController.targetDog = dogToBeOpened!
        }
        
    }
    
    @objc private func willOpenDog(sender: UIButton) {
        if sender.tag == 0 {
            self.willOpenDog(dogToBeOpened: nil, isAddingRequirement: false)
        }
        else {
            self.willOpenDog(dogToBeOpened: getDogManager().dogs[sender.tag-1], isAddingRequirement: true)
        }
    }
    
    //MARK: Programmically Added Add Requirement To Dog / Add Dog Buttons
    
    private var universalTapGesture: UITapGestureRecognizer!
    private var dimScreenView: UIView!
    private var dismissAddDogTap: UITapGestureRecognizer!
    
    private var addStatus: Bool = false
    
    private var addButtons: [ScaledButton] = []
    private var addButtonsBackground: [ScaledButton] = []
    private var addButtonsLabel: [UILabel] = []
    private var addButtonsLabelBackground: [UILabel] = []
    
    ///For selector in UITapGestureRecognizer
    @objc private func toggleAddStatusToFalse(){
        changeAddStatus(newAddStatus: false)
    }
    
    ///Changes the status of the subAddButtons which navigate to add a dog, add a requirement for "DOG NAME", add a requirement for "DOG NAME 2" etc, from present and active to hidden, includes animation
    private func changeAddStatus(newAddStatus: Bool){
        
        ///Toggles to adding
        if newAddStatus == true{
            //Slight correction with last () as even with the correct corrindates for aligned trailing for some reason the the new subbuttons slightly bluge out when they should be conceiled by the WillAddButton.
            let originXWithAlignedTrailing: CGFloat = (willAddButton.frame.origin.x+willAddButton.frame.width)-subButtonSize-(willAddButton.frame.size.width*0.035)
            
            //Creates the "add new dog" button to click
            let willAddDogButton = ScaledButton(frame: CGRect(origin: CGPoint(x: originXWithAlignedTrailing, y: willAddButton.frame.origin.y - 10 - subButtonSize), size: CGSize(width: subButtonSize, height: subButtonSize)))
            willAddDogButton.setImage(UIImage(systemName: "plus.circle")!, for: .normal)
            willAddDogButton.tintColor = .systemBlue
            willAddDogButton.tag = 0
            willAddDogButton.addTarget(self, action: #selector(willOpenDog(sender:)), for: .touchUpInside)
            
            //Create white background layered behind original button as middle is see through
            let willAddDogButtonBackground = createAddButtonBackground(willAddDogButton)
            
            let willAddDogButtonLabel = createAddButtonLabel(willAddDogButton, text: "Add A New Dog")
            let willAddDogButtonLabelBackground = createAddButtonLabelBackground(willAddDogButtonLabel)
            
            addButtons.append(willAddDogButton)
            addButtonsBackground.append(willAddDogButtonBackground)
            addButtonsLabel.append(willAddDogButtonLabel)
            addButtonsLabelBackground.append(willAddDogButtonLabelBackground)
            
            //Goes through all the dogs and create a corresponding button for them so you can add a reminder ro them
            for dogIndex in 0..<getDogManager().dogs.count{
                guard maximumSubButtonCount > addButtons.count else {
                    break
                }
                
                //creates clickable button with a position that it relative to the subbutton below it
                let willAddRequirementButton = ScaledButton(frame: CGRect(origin: CGPoint(x: addButtons.last!.frame.origin.x, y: addButtons.last!.frame.origin.y - 10 - subButtonSize), size: CGSize(width: subButtonSize, height: subButtonSize)))
                willAddRequirementButton.setImage(UIImage(systemName: "plus.circle")!, for: .normal)
                willAddRequirementButton.tintColor = .systemBlue
                willAddRequirementButton.tag = dogIndex+1
                willAddRequirementButton.addTarget(self, action: #selector(willOpenDog(sender:)), for: .touchUpInside)
                
                let willAddRequirementButtonBackground = createAddButtonBackground(willAddRequirementButton)
                
                let willAddRequirementButtonLabel = createAddButtonLabel(willAddRequirementButton, text: "Add A Reminder For \(getDogManager().dogs[dogIndex].dogTraits.dogName)")
                let willAddRequirementButtonLabelBackground = createAddButtonLabelBackground(willAddRequirementButtonLabel)
                
                addButtons.append(willAddRequirementButton)
                addButtonsBackground.append(willAddRequirementButtonBackground)
                addButtonsLabel.append(willAddRequirementButtonLabel)
                addButtonsLabelBackground.append(willAddRequirementButtonLabelBackground)
            }
            //goes through all buttons, labels, and their background and animates them to their correct position
            for buttonIndex in 0..<addButtons.count{
                
                self.dismissAddDogTap.isEnabled = true
                
                let button = addButtons[buttonIndex]
                let buttonBackground = addButtonsBackground[buttonIndex]
                let buttonLabel = addButtonsLabel[buttonIndex]
                let buttonLabelBackground = addButtonsLabelBackground[buttonIndex]
                
                let buttonOrigin = button.frame.origin
                let buttonLabelOrigin = buttonLabel.frame.origin
                
                let originYWithAlignedMiddle = willAddButton.frame.midY - (button.frame.height/2)
                
                button.frame.origin.y = originYWithAlignedMiddle
                buttonBackground.frame.origin.y = originYWithAlignedMiddle
                
                buttonLabel.frame.origin.x = self.view.safeAreaLayoutGuide.layoutFrame.maxX
                buttonLabelBackground.frame.origin.x = self.view.safeAreaLayoutGuide.layoutFrame.maxX
                
                view.addSubview(buttonLabelBackground)
                view.addSubview(buttonLabel)
                view.addSubview(buttonBackground)
                view.addSubview(button)
                
                UIView.animate(withDuration: AnimationConstant.largeButtonShow.rawValue) {
                    self.willAddButton.transform = CGAffineTransform(rotationAngle: -.pi/4)
                    self.willAddButtonBackground.transform = CGAffineTransform(rotationAngle: -.pi/4)
                    self.willAddButton.tintColor = .systemRed
                    
                    button.frame.origin = buttonOrigin
                    buttonBackground.frame.origin = buttonOrigin
                    buttonLabel.frame.origin = buttonLabelOrigin
                   buttonLabelBackground.frame.origin = buttonLabelOrigin
                    
                    self.dimScreenView.alpha = 0.66
                    MainTabBarViewController.mainTabBarViewController.tabBar.alpha = 0.06
                    MainTabBarViewController.mainTabBarViewController.dogsNavigationViewController.navigationBar.alpha = 0.06
                    
                } completion: { (completed) in
                    //
                }

            }
            view.bringSubviewToFront(willAddButtonBackground)
            view.bringSubviewToFront(willAddButton)
            
        }
        else if newAddStatus == false{
            for buttonIndex in 0..<addButtons.count{
                
                self.dismissAddDogTap.isEnabled = false
                
                let button = addButtons[buttonIndex]
                let buttonBackground = addButtonsBackground[buttonIndex]
                let buttonLabel = addButtonsLabel[buttonIndex]
                let buttonLabelBackground = addButtonsLabelBackground[buttonIndex]
                
                let originYWithAlignedMiddle = willAddButton.frame.midY - (button.frame.height/2)
                
                UIView.animate(withDuration: AnimationConstant.largeButtonShow.rawValue) {
                    self.willAddButton.transform = .identity
                    self.willAddButtonBackground.transform = .identity
                    self.willAddButton.tintColor = .systemBlue
                    
                    button.frame.origin.y = originYWithAlignedMiddle
                    buttonBackground.frame.origin.y = originYWithAlignedMiddle
                    
                    buttonLabel.frame.origin.x = self.view.safeAreaLayoutGuide.layoutFrame.maxX
                    buttonLabelBackground.frame.origin.x = self.view.safeAreaLayoutGuide.layoutFrame.maxX
                    
                    self.dimScreenView.alpha = 0
                    MainTabBarViewController.mainTabBarViewController.tabBar.alpha = 1
                    MainTabBarViewController.mainTabBarViewController.dogsNavigationViewController.navigationBar.alpha = 1
                    
                } completion: { (completed) in
                    DispatchQueue.main.asyncAfter(deadline: .now() + AnimationConstant.largeButtonHide.rawValue) {
                        button.isHidden = true
                        button.removeFromSuperview()
                        buttonBackground.isHidden = true
                        buttonBackground.removeFromSuperview()
                        buttonLabel.isHidden = true
                        buttonLabel.removeFromSuperview()
                        buttonLabelBackground.isHidden = true
                        buttonLabelBackground.removeFromSuperview()
                    }
                }

            }
            addButtons.removeAll()
            addButtonsBackground.removeAll()
            addButtonsLabel.removeAll()
            addButtonsLabelBackground.removeAll()
        }
        addStatus = newAddStatus
    }
    
    //MARK: changeAddStatus Helper Functions
    
    ///Creates a label for a given add button with the specified text, handles all frame, origin, and size related things
    private func createAddButtonLabel(_ button: ScaledButton, text: String) -> UILabel {
        let buttonLabelFont = UIFont.systemFont(ofSize: 17, weight: .semibold)
        let buttonLabelSize = text.withBounded(font: buttonLabelFont)
        let buttonLabel = UILabel(frame: CGRect(origin: CGPoint (x: button.frame.origin.x - buttonLabelSize.width, y: button.frame.midY - (buttonLabelSize.height/2)),size: buttonLabelSize ))
            
        buttonLabel.attributedText = NSAttributedString(string: text, attributes: [.font: buttonLabelFont])
        buttonLabel.textColor = .white
        
        //buttonLabel.isHidden = true
        
        buttonLabel.isUserInteractionEnabled = false
        buttonLabel.adjustsFontSizeToFitWidth = true
         
        return buttonLabel
    }
    
    ///Creates a label for a given add button with the specified text, handles all frame, origin, and size related things
    private func createAddButtonLabelBackground(_ label: UILabel) -> UILabel {
        let buttonLabel = UILabel(frame: label.frame)
        buttonLabel.font = label.font
        buttonLabel.text = label.text
        buttonLabel.outline(outlineColor: .systemBlue, insideColor: .systemBlue, outlineWidth: 15)
        
        buttonLabel.isUserInteractionEnabled = false
        buttonLabel.adjustsFontSizeToFitWidth = true
         
        return buttonLabel
    }
    
    private func createAddButtonBackground(_ button: ScaledButton) -> ScaledButton {
        let buttonBackground = ScaledButton(frame: button.frame)
        buttonBackground.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        buttonBackground.tintColor = .white
        buttonBackground.isUserInteractionEnabled = false
        return buttonBackground
    }
    
    //MARK: changeAddStatus Calculated Variables
    
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
    
    ///Calculates total Y space available, from the botton of the thinBlackLine below the pageTitle to the top of the willAddButton
    private var subButtonTotalAvailableYSpace: CGFloat {
        return willAddButton.frame.origin.y - view.frame.origin.y
    }
    
    ///Uses subButtonSize and subButtonTotalAvailableYSpace to figure out how many buttons can fit, rounds down, so if 2.9999 can fit then only 2 will as not enough space for third
    private var maximumSubButtonCount: Int {
        return Int(subButtonTotalAvailableYSpace / (subButtonSize + 10).rounded(.down))
    }
    
    // MARK: - Navigation
    
    ///Allows for unwind to this page when back button is clicked in requirement editor
    @IBAction func unwind(_ seg: UIStoryboardSegue){
        
    }
    
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

