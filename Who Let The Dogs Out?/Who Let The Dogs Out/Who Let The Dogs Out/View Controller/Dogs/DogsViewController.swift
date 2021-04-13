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
        
        willOpenDog(dogToBeOpened: getDogManager().dogs[dogIndex], isAddingRequirement: false)
        
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
        
        let dimView = UIView(frame: self.view.frame)
        dimView.alpha = 0
        //dimView.backgroundColor = UIColor.init(hue: 0.0, saturation: 0.0, brightness: 0.66, alpha: 1.0)
        dimView.backgroundColor = UIColor.black
        dimScreenView = dimView
        self.view.addSubview(dimView)
        
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
    private func willOpenDog(dogToBeOpened: Dog? = nil, isAddingRequirement: Bool = false){
        
        self.performSegue(withIdentifier: "dogsAddDogViewController", sender: self)
        
        
        ///Is opening a dog
        if dogToBeOpened != nil {
        //Conversion of "DogsAddDogViewController" to update mode
            if isAddingRequirement == true {
                dogsAddDogViewController.dogsRequirementNavigationViewController.dogsRequirementTableViewController.performSegue(withIdentifier: "dogsInstantiateRequirementViewController", sender: self)
            }
            
        dogsAddDogViewController.isUpdating = true
        dogsAddDogViewController.targetDog = dogToBeOpened!
        dogsAddDogViewController.willInitalize()
            dogsAddDogViewController.pageTitle.text = "Update Dog"
            
        }
        else {
            dogsAddDogViewController.pageTitle.text = "Create Dog"
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
    
    private var dimScreenView: UIView!
    private var addStatus: Bool = false
    private var addButtons: [ScaledButton] = []
    private var addButtonsBackground: [ScaledButton] = []
    private var addButtonsLabel: [UILabel] = []
    private var addButtonsLabelBackground: [UILabel] = []
    
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
            
            let willAddDogButtonBackground = createAddButtonBackground(willAddDogButton)
            
            let willAddDogButtonLabel = createAddButtonLabel(willAddDogButton, text: "Add A New Dog")
            let willAddDogButtonLabelBackground = createAddButtonLabelBackground(willAddDogButtonLabel)
            
            addButtons.append(willAddDogButton)
            addButtonsBackground.append(willAddDogButtonBackground)
            addButtonsLabel.append(willAddDogButtonLabel)
           addButtonsLabelBackground.append(willAddDogButtonLabelBackground)
            
            for dogIndex in 0..<getDogManager().dogs.count{
                guard maximumSubButtonCount > addButtons.count else {
                    break
                }
                
                let willAddRequirementButton = ScaledButton(frame: CGRect(origin: CGPoint(x: addButtons.last!.frame.origin.x, y: addButtons.last!.frame.origin.y - 10 - subButtonSize), size: CGSize(width: subButtonSize, height: subButtonSize)))
                //TRADITIONAL willAddRequirementButton.setImage(UIImage(systemName: "plus.circle.fill")!, for: .normal)
                willAddRequirementButton.setImage(UIImage(systemName: "plus.circle")!, for: .normal)
                willAddRequirementButton.tintColor = .link
                willAddRequirementButton.tag = dogIndex+1
                willAddRequirementButton.addTarget(self, action: #selector(willOpenDog(sender:)), for: .touchUpInside)
                
                let willAddRequirementButtonBackground = createAddButtonBackground(willAddRequirementButton)
                
                let willAddRequirementButtonLabel = createAddButtonLabel(willAddRequirementButton, text: "Add A Reminder For \(try! getDogManager().dogs[dogIndex].dogSpecifications.getDogSpecification(key: "name"))")
                let willAddRequirementButtonLabelBackground = createAddButtonLabelBackground(willAddRequirementButtonLabel)
                
                addButtons.append(willAddRequirementButton)
                addButtonsBackground.append(willAddRequirementButtonBackground)
                addButtonsLabel.append(willAddRequirementButtonLabel)
                addButtonsLabelBackground.append(willAddRequirementButtonLabelBackground)
            }
            for buttonIndex in 0..<addButtons.count{
                let button = addButtons[buttonIndex]
                let buttonBackground = addButtonsBackground[buttonIndex]
                let buttonLabel = addButtonsLabel[buttonIndex]
                let buttonLabelBackground = addButtonsLabelBackground[buttonIndex]
                
                let buttonOrigin = button.frame.origin
                let buttonLabelOrigin = buttonLabel.frame.origin
                
                let originYWithAlignedMiddle = willAddButton.frame.midY - (button.frame.height/2)
                
                button.frame.origin.y = originYWithAlignedMiddle
                buttonBackground.frame.origin = button.frame.origin
                buttonLabel.frame.origin.x = self.view.safeAreaLayoutGuide.layoutFrame.maxX
                buttonLabelBackground.frame.origin.x = self.view.safeAreaLayoutGuide.layoutFrame.maxX
                
                view.addSubview(buttonLabelBackground)
                view.addSubview(buttonLabel)
                view.addSubview(buttonBackground)
                view.addSubview(button)
                
                UIView.animate(withDuration: AnimationConstant.largeButtonShow.rawValue) {
                    button.frame.origin = buttonOrigin
                    buttonBackground.frame.origin = buttonOrigin
                    buttonLabel.frame.origin = buttonLabelOrigin
                   buttonLabelBackground.frame.origin = buttonLabelOrigin
                    self.dimScreenView.alpha = 0.66
                    MainTabBarViewController.mainTabBarViewController.tabBar.alpha = 0.1
                    
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
                let buttonLabel = addButtonsLabel[buttonIndex]
                let buttonLabelBackground = addButtonsLabelBackground[buttonIndex]
                
                let originYWithAlignedMiddle = willAddButton.frame.midY - (button.frame.height/2)
                
                UIView.animate(withDuration: AnimationConstant.largeButtonShow.rawValue) {
                    
                    
                    button.frame.origin.y = originYWithAlignedMiddle
                    buttonBackground.frame.origin.y = originYWithAlignedMiddle
                    buttonLabel.frame.origin.x = self.view.safeAreaLayoutGuide.layoutFrame.maxX
                    buttonLabelBackground.frame.origin.x = self.view.safeAreaLayoutGuide.layoutFrame.maxX
                    self.dimScreenView.alpha = 0
                    MainTabBarViewController.mainTabBarViewController.tabBar.alpha = 1
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
        buttonLabel.outline(outlineColor: .link, insideColor: .link, outlineWidth: 15)
        
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
    
    @IBAction func willAddButton(_ sender: Any) {
        self.changeAddStatus(newAddStatus: !addStatus)
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

