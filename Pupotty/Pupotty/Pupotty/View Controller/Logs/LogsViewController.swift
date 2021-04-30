//
//  LogsViewController.swift
//  Pupotty
//
//  Created by Jonathan Xakellis on 4/17/21.
//  Copyright © 2021 Jonathan Xakellis. All rights reserved.
//

import UIKit

protocol LogsViewControllerDelegate{
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager)
}

class LogsViewController: UIViewController, DogManagerControlFlowProtocol, LogsMainScreenTableViewControllerDelegate, MakeDropDownDataSourceProtocol {
    
    
    
    //MARK: - LogsMainScreenTableViewControllerDelegate
    
    func didUpdateDogManager(sender: Sender, newDogManager: DogManager) {
        setDogManager(sender: sender, newDogManager: newDogManager)
    }
    
    //MARK: - MakeDropDownDataSourceProtocol
    
    private var dropDownRowHeight: CGFloat = 30
    
    func configureCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, makeDropDownIdentifier: String) {
        if makeDropDownIdentifier == "DROP_DOWN_NEW"{
            let customCell = cell as! DropDownTableViewCell
            
            
            if indexPath.row == 0 {
                customCell.requirementName.attributedText = NSAttributedString(string: getDogManager().dogs[indexPath.section].dogTraits.dogName, attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .semibold)])
            }
            else {
                customCell.requirementName.attributedText = NSAttributedString(string: getDogManager().dogs[indexPath.section].dogRequirments.requirements[indexPath.row-1].requirementName, attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .regular)])
            }
            
            if indexPath == filterIndexPath{
                customCell.didToggleSelect(newSelectionStatus: true)
            }
            else {
                customCell.didToggleSelect(newSelectionStatus: false)
            }
            
        }
    }
    
    func numberOfRows(forSection: Int) -> Int {
        let sudoDogManager = getDogManager()
        var count = 1
            for _ in sudoDogManager.dogs[forSection].dogRequirments.requirements{
                count = count + 1
            }
        
        if count == 0{
            return 1
        }
        else {
            return count
        }
    }
    
    func numberOfSections() -> Int {
        let sudoDogManager = getDogManager()
        var count = 0
        for _ in sudoDogManager.dogs{
            count = count + 1
        }
        if count == 0{
            return 1
        }
        else {
            return count
        }
    }
    
    func selectItemInDropDown(indexPath: IndexPath, makeDropDownIdentifier: String) {
        let selectedCell = dropDown.dropDownTableView!.cellForRow(at: indexPath) as! DropDownTableViewCell
        
        //already filtering, now not filtering
        if filterIndexPath == indexPath {
            selectedCell.didToggleSelect(newSelectionStatus: false)
            
            filterIndexPath = nil
        }
        //not filtering, now will filter
        else if filterIndexPath == nil{
            selectedCell.didToggleSelect(newSelectionStatus: true)
            
            filterIndexPath = indexPath
        }
        //switching from one filter to another
        else {
            let unselectedCell = dropDown.dropDownTableView!.cellForRow(at: filterIndexPath!) as! DropDownTableViewCell
            unselectedCell.didToggleSelect(newSelectionStatus: false)
            selectedCell.didToggleSelect(newSelectionStatus: true)
            
            filterIndexPath = indexPath
        }
        
        self.dropDown.hideDropDown()
    }
    
    //MARK: - DogManagerControlFlowProtocol
    
    private var dogManager: DogManager = DogManager()
    
    func getDogManager() -> DogManager {
        //DogManagerEfficencyImprovement return dogManager.copy() as! DogManager
        return dogManager
    }
    
    func setDogManager(sender: Sender, newDogManager: DogManager) {
        //DogManagerEfficencyImprovement dogManager = newDogManager.copy() as! DogManager
        dogManager = newDogManager
        
        if sender.localized is MainTabBarViewController{
            logsMainScreenTableViewController?.setDogManager(sender: Sender(origin: sender, localized: self), newDogManager: dogManager)
            filterIndexPath = nil
        }
        if sender.localized is LogsMainScreenTableViewController{
            delegate.didUpdateDogManager(sender: Sender(origin: sender, localized: self), newDogManager: dogManager)
        }
    }
    
    func updateDogManagerDependents() {
        //
    }
    
    //MARK: - IB
    
    @IBOutlet weak var button: UIButton!
    
    @IBAction private func willShowFilter(_ sender: Any) {
        
        var numRowsDisplayed: Int {
            
            var totalCount: Int {
                var count = 0
                for dog in getDogManager().dogs{
                    count = count + 1
                    for _ in dog.dogRequirments.requirements{
                        count = count + 1
                    }
                }
                
                if count == 0{
                    return 1
                }
                return count
            }
            
                let maximumHeight = self.view.safeAreaLayoutGuide.layoutFrame.size.height
                let neededHeight = self.dropDownRowHeight * CGFloat(totalCount)
                
                if neededHeight < maximumHeight{
                    return totalCount
                }
                else {
                    return Int((maximumHeight / dropDownRowHeight).rounded(.down))
                }
        
        }
        self.dropDown.showDropDown(height: dropDownRowHeight * CGFloat(numRowsDisplayed), selectedIndexPath: self.filterIndexPath)
        
        
    }
    
    //MARK: - Properties
    
    private let dropDown = MakeDropDown()
    
    private var storedFilterIndexPath: IndexPath? = nil
    private var filterIndexPath: IndexPath? {
        get {
            return storedFilterIndexPath
        }
        set(newIndexPath){
            storedFilterIndexPath = newIndexPath
            logsMainScreenTableViewController?.willApplyFiltering(associatedToIndexPath: newIndexPath)
        }
    }
    
    var logsMainScreenTableViewController: LogsMainScreenTableViewController! = nil
    
    var delegate: LogsViewControllerDelegate! = nil
    
    //MARK: - Main

    override func viewDidLoad() {
        super.viewDidLoad()

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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        dropDown.hideDropDown()
    }
    
    //MARK: - Drop Down Functions
    
    private func setUpDropDown(){
        
        ///Finds the widthNeeded by the largest label, has a minimum and maximum possible along with subtracting the space taken by leading and trailing constraints.
        var neededWidthForLabel: CGFloat{
            let maximumWidth: CGFloat = view.safeAreaLayoutGuide.layoutFrame.width - 20.0
            let minimumWidth: CGFloat = 100.0 - 20.0
            
            ///Finds the largestWidth taken up by any label, later compared to constraint sizes of min and max
            var largestLabelWidth: CGFloat {
                /*
                 if indexPath.row == 0 {
                     customCell.requirementName.attributedText = NSAttributedString(string: getDogManager().dogs[indexPath.section].dogTraits.dogName, attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .semibold)])
                 }
                 else {
                     customCell.requirementName.attributedText = NSAttributedString(string: getDogManager().dogs[indexPath.section].dogRequirments.requirements[indexPath.row-1].requirementName, attributes: [.font: UIFont.systemFont(ofSize: 15, weight: .regular)])
                 }
                 */
                let sudoDogManager = getDogManager()
                var largest: CGFloat = 0.0
                
                for dogIndex in 0..<sudoDogManager.dogs.count{
                    let dog = sudoDogManager.dogs[dogIndex]
                    let dogNameWidth = dog.dogTraits.dogName.boundingFrom(font: UIFont.systemFont(ofSize: 20, weight: .semibold), height: 30.0).width
                    
                    if dogNameWidth > largest {
                        largest = dogNameWidth
                    }
                    
                    for requirementIndex in 0..<dog.dogRequirments.requirements.count{
                        let requirement = dog.dogRequirments.requirements[requirementIndex]
                        let requirementNameWidth = requirement.requirementName.boundingFrom(font: UIFont.systemFont(ofSize: 15, weight: .regular), height: 30.0).width
                        
                        if requirementNameWidth > largest {
                            largest = requirementNameWidth
                        }
                        
                    }
                }
                
                return largest
            }
            
            switch largestLabelWidth {
            case 0..<minimumWidth:
                return minimumWidth
            case minimumWidth...maximumWidth:
                return largestLabelWidth
            default:
                return maximumWidth
            }
        }
        
        dropDown.makeDropDownIdentifier = "DROP_DOWN_NEW"
        dropDown.cellReusableIdentifier = "dropDownCell"
        dropDown.makeDropDownDataSourceProtocol = self
        dropDown.setUpDropDown(viewPositionReference: (CGRect(origin: self.view.safeAreaLayoutGuide.layoutFrame.origin, size: CGSize(width: neededWidthForLabel + 20.0, height: 0.0))), offset: 0.0)
        dropDown.nib = UINib(nibName: "DropDownTableViewCell", bundle: nil)
        dropDown.setRowHeight(height: self.dropDownRowHeight)
        self.view.addSubview(dropDown)
    }
    
    // MARK: - Navigation
    
    ///Allows for unwind to this page when back button is clicked in requirement editor
    @IBAction func unwind(_ seg: UIStoryboardSegue){
        
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "logsMainScreenTableViewController"{
            logsMainScreenTableViewController = segue.destination as? LogsMainScreenTableViewController
            logsMainScreenTableViewController.setDogManager(sender: Sender(origin: self, localized: self), newDogManager: getDogManager())
            logsMainScreenTableViewController.delegate = self
        }
    }
    

}
