//
//  ReportInfoTableViewController.swift
//  Roadster
//
//  Created by EA JA on 6/19/17.
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit

class ReportInfoTableViewController: UITableViewController {

    var restStop: USRestStop!
    @IBOutlet var closedSwitch: UISwitch!
    @IBOutlet var mileMarkerTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Report Info"
        configureStopInformationSection()
        
    }
    
    func configureStopInformationSection(){
        if restStop.closed{
            closedSwitch.isOn = true
        } else {
            closedSwitch.isOn = false
        }
        
        mileMarkerTextField.text = restStop.mileMarker
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func submit(_ sender: UIButton){
    
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

            return 44.0
        
    }
    
    
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 2 else {return super.tableView(tableView, viewForHeaderInSection: section)}
        return getHeaderViewLabel()
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard section == 0 || section == 1 else {return}
        
        let headerView = view as? UITableViewHeaderFooterView
        headerView!.textLabel?.font = UIFont.systemFont(ofSize: 14)
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 1 && indexPath.row == 0{
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            if restStop.disabledFacilities{
                cell.accessoryType = .checkmark
            }
            return cell
        } else if indexPath.section == 1 && indexPath.row == 1{
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            if restStop.gas{
                cell.accessoryType = .checkmark
            }
            return cell
        } else if indexPath.section == 1 && indexPath.row == 2{
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            if restStop.petArea{
                cell.accessoryType = .checkmark
            }
            return cell
        } else if indexPath.section == 1 && indexPath.row == 3 {
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            if restStop.phone{
                cell.accessoryType = .checkmark
            }
            return cell
        } else if indexPath.section == 1 && indexPath.row == 4 {
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            if restStop.restaurant{
                cell.accessoryType = .checkmark
            }
            return cell
        } else if indexPath.section == 1 && indexPath.row == 5 {
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            if restStop.restroom{
                cell.accessoryType = .checkmark
            }
            return cell
        } else if indexPath.section == 1 && indexPath.row == 6 {
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            if restStop.rvDump{
                cell.accessoryType = .checkmark
            }
            return cell
        } else if indexPath.section == 1 && indexPath.row == 7 {
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            if restStop.tables {
                cell.accessoryType = .checkmark
            }
            return cell
        } else if indexPath.section == 1 && indexPath.row == 8 {
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            if restStop.vendingMachine {
                cell.accessoryType = .checkmark
            }
            return cell
        } else if indexPath.section == 1 && indexPath.row == 9 {
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            if restStop.water {
                cell.accessoryType = .checkmark
            }
            return cell
        } else if indexPath.section == 1 && indexPath.row == 10 {
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            if restStop.trucks{
                cell.accessoryType = .checkmark
            }
            return cell
        } else if indexPath.section == 1 && indexPath.row == 11{
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            cell.accessoryType = .checkmark
            return cell
        }else {
            return super.tableView(tableView, cellForRowAt: indexPath)
        }
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.section == 0 || indexPath.section == 2{
            return nil
        } else {
            return indexPath
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)!
        if cell.accessoryType == .none{
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
    }
    
   
    
    func getHeaderViewLabel() -> UITextView{
        let headerView = UITextView()
        headerView.text = "Please tap on the options above to select the available facilities at this rest stop."
        headerView.font = UIFont.systemFont(ofSize: 14)
        headerView.textAlignment = .left
        headerView.isEditable = false
        headerView.isSelectable = false
        headerView.textContainerInset = UIEdgeInsets(top: 5, left: 10, bottom: 0, right: 10)
        headerView.backgroundColor = UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1.0)
        headerView.sizeToFit()
        
        return headerView
    }
    
    
   

}
