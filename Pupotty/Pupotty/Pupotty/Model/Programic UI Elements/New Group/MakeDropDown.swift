//
//  MakeDropDown.swift
//  MakeDropDown
//
//  Created by ems on 02/05/19.
//  Copyright © 2019 Majesco. All rights reserved.
//

import Foundation
import UIKit
protocol MakeDropDownDataSourceProtocol{
    func configureCellForDropDown(cell: UITableViewCell, indexPath: IndexPath, makeDropDownIdentifier: String)
    ///Returns number of rows in a given section of the dropDownMenu
    func numberOfRows(forSection: Int, makeDropDownIdentifier: String) -> Int
    ///Returns number section in the dropDownMenu
    func numberOfSections(makeDropDownIdentifier: String) -> Int
    
    ///Called when an item is selected in the dropdown menu
    func selectItemInDropDown(indexPath: IndexPath, makeDropDownIdentifier: String)
}

class MakeDropDown: UIView{
    
    //MARK: - Variables
    /// The DropDownIdentifier is to differentiate if you are using multiple Xibs
    var makeDropDownIdentifier: String = "DROP_DOWN"
    /// Reuse Identifier of your custom cell
    var cellReusableIdentifier: String = "DROP_DOWN_CELL"
    // Table View
    var dropDownTableView: UITableView?
    private var width: CGFloat = 0
    private var offset:CGFloat = 0
    var makeDropDownDataSourceProtocol: MakeDropDownDataSourceProtocol?
    var nib: UINib?{
        didSet{
            dropDownTableView?.register(nib, forCellReuseIdentifier: self.cellReusableIdentifier)
        }
    }
    // Other Variables
    private var viewPositionRef: CGRect?
    private var isDropDownPresent: Bool = false
   
    
    //MARK: - DropDown Methods
    
    /// Make Table View Programatically
    func setUpDropDown(viewPositionReference: CGRect,  offset: CGFloat){
        self.addBorders()
        self.addShadowToView()
        self.frame = CGRect(x: viewPositionReference.minX, y: viewPositionReference.maxY + offset, width: 0, height: 0)
        dropDownTableView = UITableView(frame: CGRect(x: self.frame.minX, y: self.frame.minY, width: 0, height: 0))
        self.width = viewPositionReference.width
        self.offset = offset
        self.viewPositionRef = viewPositionReference
        dropDownTableView?.showsVerticalScrollIndicator = false
        dropDownTableView?.showsHorizontalScrollIndicator = false
        dropDownTableView?.backgroundColor = .white
        dropDownTableView?.separatorStyle = .none
        dropDownTableView?.delegate = self
        dropDownTableView?.dataSource = self
        dropDownTableView?.allowsSelection = true
        dropDownTableView?.isUserInteractionEnabled = true
        dropDownTableView?.tableFooterView = UIView()
        self.addSubview(dropDownTableView!)
        
    }
    
    /// Shows Drop Down Menu, hides it if already present
    func showDropDown(height: CGFloat, selectedIndexPath: IndexPath? = nil){
        if isDropDownPresent == true{
            self.hideDropDown()
        }
        else{
            reloadDropDownData()
            isDropDownPresent = true
            self.frame = CGRect(x: (self.viewPositionRef?.minX)!, y: (self.viewPositionRef?.maxY)! + self.offset, width: width, height: 0)
            self.dropDownTableView?.frame = CGRect(x: 0, y: 0, width: width, height: 0)
            
            UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.05, options: .curveLinear
                , animations: {
                self.frame.size = CGSize(width: self.width, height: height)
                self.dropDownTableView?.frame.size = CGSize(width: self.width, height: height)
            })
        }
        
    }
    
    ///Reloads table view data
    private func reloadDropDownData(){
        self.dropDownTableView?.reloadData()
    }
    
    ///Sets Row Height of your Custom XIB
    func setRowHeight(height: CGFloat){
        self.dropDownTableView?.rowHeight = height
        self.dropDownTableView?.estimatedRowHeight = height
    }
    
    ///Hides DropDownMenu
    func hideDropDown(removeFromSuperview shouldRemoveFromSuperview: Bool = false){
        if isDropDownPresent == true {
            isDropDownPresent = false
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.3, options: .curveLinear
                , animations: {
                    self.frame.size = CGSize(width: self.width, height: 0)
                    self.dropDownTableView?.frame.size = CGSize(width: self.width, height: 0)
            }) { (_) in
                if shouldRemoveFromSuperview == true {
                    self.removeFromSuperview()
                    self.dropDownTableView?.removeFromSuperview()
                }
                
            }
        }
    }
}

// MARK: - Table View Methods

extension MakeDropDown: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return (makeDropDownDataSourceProtocol?.numberOfSections(makeDropDownIdentifier: self.makeDropDownIdentifier) ?? 0)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (makeDropDownDataSourceProtocol?.numberOfRows(forSection: section, makeDropDownIdentifier: self.makeDropDownIdentifier) ?? 0)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = (dropDownTableView?.dequeueReusableCell(withIdentifier: self.cellReusableIdentifier) ?? UITableViewCell())
        
        makeDropDownDataSourceProtocol?.configureCellForDropDown(cell: cell, indexPath: indexPath, makeDropDownIdentifier: self.makeDropDownIdentifier)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        makeDropDownDataSourceProtocol?.selectItemInDropDown(indexPath: indexPath, makeDropDownIdentifier: self.makeDropDownIdentifier)
    }
    
}
//MARK: - UIView Extension
extension UIView{
    func addBorders(borderWidth: CGFloat = 0.2, borderColor: CGColor = UIColor.lightGray.cgColor){
        self.layer.borderWidth = borderWidth
        self.layer.borderColor = borderColor
    }
    
    func addShadowToView(shadowRadius: CGFloat = 2, alphaComponent: CGFloat = 0.6) {
        self.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: alphaComponent).cgColor
        self.layer.shadowOffset = CGSize(width: -1, height: 2)
        self.layer.shadowRadius = shadowRadius
        self.layer.shadowOpacity = 1
    }
}
