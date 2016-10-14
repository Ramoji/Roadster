//
//  FirstViewController.swift
//  Roadster
//
//  Created by A Ja on 9/6/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

import UIKit
import CoreData

struct CustomCellTypeIdentifiers {
    static let CellWithImageView = "CellWithImageView"
    static let NoRestStopsCell = "NoRestStopsCell"
}

class StateListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var managedObjectContext: NSManagedObjectContext!
    var states: States!
    var filteredStateList: [(String, String)]!
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        registerNibs()
        
    }
    
    override func loadView() {
        super.loadView()
        setUpSearchController()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    
    }
    
    func setUpSearchController(){
    
        searchController = UISearchController(searchResultsController: nil)
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.dimsBackgroundDuringPresentation = true
        searchController.dimsBackgroundDuringPresentation = false
        tableView.tableHeaderView = searchController.searchBar
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        definesPresentationContext = true
    }
    
    func registerNibs(){
        let cellNib = UINib(nibName: CustomCellTypeIdentifiers.CellWithImageView, bundle: nil)
        tableView.register(cellNib , forCellReuseIdentifier: CustomCellTypeIdentifiers.CellWithImageView)
    }
    
    func setUpTableView(){
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 77, bottom: 0, right: 0)
        tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableViewScrollPosition.top, animated: false)
    }
    
}

//MARK: - TableViewDelegate

extension StateListViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)
        if let cell = cell {
        performSegue(withIdentifier: "showHighwayList", sender: cell)
        }
    }
}

//MARK: - TableViewDataSource

extension StateListViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchController.isActive && searchController.searchBar.text != ""{
            return filteredStateList.count
        } else {
            return states.numberOfStates()
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.CellWithImageView, for: indexPath) as! CellWithImageView
        
        if searchController.isActive && searchController.searchBar.text != ""{
            let element = filteredStateList[indexPath.row]
            cell.configureCell(forState: element)
            
        } else {
            let element = states.stateNamesAndNicknamesElement(forIndex: (indexPath as NSIndexPath).row)
            cell.configureCell(forState: element)
        }
        return cell
    }
}

extension StateListViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {
       let list = states.stateNamesAndNicknamesDictionary()
        filteredStateList = list.filter({
            element in
            return element.0.contains(searchController.searchBar.text!)
        })
        tableView.reloadData()
    }
}

extension StateListViewController: UISearchControllerDelegate{
}

//MARK: - Segues
extension StateListViewController{
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showHighwayList"{
            let cell = sender as! CellWithImageView
            let stateName = cell.stateNameLabel.text
            let highwayListViewController = segue.destination as! HighwayListViewController
            highwayListViewController.managedObjectContext = self.managedObjectContext
            highwayListViewController.states = self.states
            highwayListViewController.stateName = stateName
        }
    }
}







