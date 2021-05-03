//
//  LogsAddArbitraryLogViewController.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 4/30/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol LogsAddArbitraryLogViewControllerDelegate {
    func didAddArbitraryLog(sender: Sender, parentDogName: String, newArbitraryLog: ArbitraryLog) throws
}

class LogsAddArbitraryLogViewController: UIViewController, UITextFieldDelegate, UIGestureRecognizerDelegate, MakeDropDownDataSourceProtocol {
    
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    //MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    //MARK: - MakeDropDownDataSourceProtocol
    
    func configureCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, makeDropDownIdentifier: String) {
        if makeDropDownIdentifier == "DROP_DOWN_NEW"{
            let customCell = cell as! DropDownParentDogTableViewCell
            
            customCell.parentDogName.text = "  ".appending(dogManager.dogs[indexPath.row].dogTraits.dogName)
        }
    }
    
    func numberOfRows(forSection: Int) -> Int {
        return dogManager.dogs.count
    }
    
    func numberOfSections() -> Int {
        return 1
    }
    
    func selectItemInDropDown(indexPath: IndexPath, makeDropDownIdentifier: String) {
        selectedParentDogName = dogManager.dogs[indexPath.row].dogTraits.dogName
        parentDogName.text = "  ".appending(selectedParentDogName)
        self.dropDown.hideDropDown()
    }
    
    //MARK: - IB
    
    @IBOutlet private weak var logDisclaimer: CustomLabel!
    
    @IBOutlet private weak var parentDogName: CustomLabel!
    
    @IBOutlet private weak var logName: UITextField!
    
    @IBOutlet private weak var logNote: UITextField!
    
    @IBOutlet private weak var logDate: UIDatePicker!
    
    @IBOutlet private weak var addLogButton: ScaledButton!
    
    @IBOutlet private weak var addLogButtonBackground: ScaledButton!
    
    @IBOutlet private weak var cancelAddLogButton: ScaledButton!
    
    @IBOutlet private weak var cancelAddLogButtonBackground: ScaledButton!
    
    @IBAction private func willAddLog(_ sender: Any) {
        self.dismissKeyboard()
        let arbitraryLog = ArbitraryLog(date: logDate.date, note: logNote.text ?? "")
        
        do {
            try arbitraryLog.changeLogName(newLogName: logName.text)
            try delegate.didAddArbitraryLog(sender: Sender(origin: self, localized: self), parentDogName: selectedParentDogName, newArbitraryLog: arbitraryLog)
            self.performSegue(withIdentifier: "unwindToLogsViewController", sender: self)
        }
        catch {
            ErrorProcessor.handleError(sender: Sender(origin: self, localized: self), error: error)
        }
    }
    
    @IBAction private func willCancel(_ sender: Any) {
        self.dismissKeyboard()
        self.performSegue(withIdentifier: "unwindToLogsViewController", sender: self)
    }
    
    @IBAction func didUpdateDatePicker(_ sender: Any) {
        self.dismissKeyboard()
    }
    
    
    
    //MARK: - Properties
    
    var dogManager: DogManager! = nil
    
    ///The last logName of an arbitraryLog, if none exist, then the last requirementName of latest logDate, if none then blank
    var lastArbitraryLogName: String? = nil
    
    ///The parentDogName selected, what the arbitrary log will be filed under
    var selectedParentDogName: String! = nil
    
    var delegate: LogsAddArbitraryLogViewControllerDelegate! = nil
    
    private let dropDown = MakeDropDown()
    
    private var dropDownRowHeight: CGFloat = 30
    
    //MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()
        guard dogManager != nil && dogManager.dogs.count != 0 else {
            if dogManager == nil{
                print("dogManager can't be nil for LogsAddArbitraryLogViewController")
            }
            else if dogManager.dogs.count == 0{
                print("dogManager has to have a dog for LogsAddArbitraryLogViewController")
            }
            self.performSegue(withIdentifier: "unwindToLogsViewController", sender: self)
            return
        }
        
        view.bringSubviewToFront(cancelAddLogButton)
        
        setupToHideKeyboardOnTapOnView()
        
        setupConstraints()
        
        setUpGestures()
        
        setupBorders()
        
        setupValues()
        
        logName.delegate = self
        logNote.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        Utils.presenter = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setUpDropDown()
    }
    
    ///Adaptable size constraint based on space the text physically take up
    private func setupConstraints(){
        logDisclaimer.frame.size = (logDisclaimer.text?.boundingFrom(font: logDisclaimer.font, width: logDisclaimer.frame.width))!
        
        logDisclaimer.constraints[0].isActive = false
    }
    
    ///Sets up gestureRecognizer for dog selector drop down
    private func setUpGestures(){
        self.parentDogName.isUserInteractionEnabled = true
        let parentDogNameTapGesture = UITapGestureRecognizer(target: self, action: #selector(parentDognameTapped))
        self.parentDogName.addGestureRecognizer(parentDogNameTapGesture)
    }
    
    
    @objc private func parentDognameTapped(){
        // Give height to drop down according to requirement
        self.dismissKeyboard()
        self.dropDown.showDropDown(height: self.dropDownRowHeight * CGFloat(dogManager.dogs.count))
    }
    
    ///Sets up light gray outline and curved corner to parentDogName
    private func setupBorders(borderWidth: CGFloat = 0.2, borderColor: CGColor = UIColor.lightGray.cgColor){
        parentDogName.layer.borderWidth = borderWidth
        parentDogName.layer.borderColor = borderColor
        parentDogName.layer.cornerRadius = 5.0
    }
    
    ///Sets up the values of different variables that is found out from information passed
    private func setupValues(){
        logName.text = lastArbitraryLogName
        
        logDate.date = Date.roundDate(targetDate: Date(), roundingInterval: 60.0*5, roundingMethod: .up)
        
        selectedParentDogName = dogManager.dogs[0].dogTraits.dogName
        parentDogName.text = "  ".appending(selectedParentDogName)
        
    }
    
    //MARK: - Drop Down Functions
    
    private func setUpDropDown(){
        dropDown.makeDropDownIdentifier = "DROP_DOWN_NEW"
        dropDown.cellReusableIdentifier = "dropDownCell"
        dropDown.makeDropDownDataSourceProtocol = self
        dropDown.setUpDropDown(viewPositionReference: parentDogName.frame, offset: 2.0)
        dropDown.nib = UINib(nibName: "DropDownParentDogTableViewCell", bundle: nil)
        dropDown.setRowHeight(height: self.dropDownRowHeight)
        self.view.addSubview(dropDown)
    }

}
