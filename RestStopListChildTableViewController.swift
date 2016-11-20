//
//  RestStopTableViewController.swift
//  Roadster
//
//  Created by A Ja on 10/15/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

protocol RestStopListChildTableViewControllerDelegate: class{
    func restStopListTable(_ childTableViewController: RestStopListChildTableViewController, didPickRestStop restStop: USRestStop)
}

import UIKit
import CoreData

class RestStopListChildTableViewController: UITableViewController {
    
    
    weak var delegate: RestStopListChildTableViewControllerDelegate?
    var blurredBackgroundView = BlurredBackgroundView(frame: CGRect.zero, addBackgroundPic: false)
    var restStopList: [USRestStop]!
    //var parentViewController: RestStopListMapViewControllerDelegate!
    
   

    override func viewDidLoad() {
        super.viewDidLoad()
        let nib = UINib(nibName: CustomCellTypeIdentifiers.NoRestStopsCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CustomCellTypeIdentifiers.NoRestStopsCell)
        tableView.isUserInteractionEnabled = true
        tableView.remembersLastFocusedIndexPath = true
        tableView.backgroundView = blurredBackgroundView
        tableView.separatorEffect = blurredBackgroundView.blurEffectView.effect
        view.backgroundColor = UIColor.clear
        
        registerNibs()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        selectFirstRow()
    }
    
    func selectFirstRow(){
        let indexPath = NSIndexPath(row: 0, section: 0)
        if restStopList.count != 0 {
            tableView.selectRow(at: indexPath as IndexPath, animated: false, scrollPosition: .top)
            delegate?.restStopListTable(self, didPickRestStop: restStopList[0])
        }
    }
    
    func registerNibs(){
        var nib = UINib(nibName: CustomCellTypeIdentifiers.CellWithImageView, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CustomCellTypeIdentifiers.CellWithImageView)
        nib = UINib(nibName: CustomCellTypeIdentifiers.NoRestStopsCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CustomCellTypeIdentifiers.NoRestStopsCell)
    }
}

//MARK: - Tableview delegate and Datasource
extension RestStopListChildTableViewController{
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if restStopList.count == 0 {
            return 1
        } else {
            return restStopList.count
        }
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if restStopList.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.NoRestStopsCell, for: indexPath) as! NoRestStopsCell
            cell.backgroundColor = UIColor.clear
            cell.accessoryType = .none
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.CellWithImageView, for: indexPath) as! CellWithImageView
            cell.stateNameLabel.text = restStopList[indexPath.row].stopName
            cell.backgroundColor = UIColor.clear
            cell.accessoryType = .none
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
        delegate?.restStopListTable(self, didPickRestStop: restStopList[indexPath.row])
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    

}








