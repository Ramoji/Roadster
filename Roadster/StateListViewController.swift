//
//  FirstViewController.swift
//  Roadster
//
//  Created by A Ja on 9/6/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

import UIKit

class StateListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    let states = StateAttributes()
    var searchResultsTableViewController: SearchResultsTableViewController!
    var filteredStateList: [(String, String)]!
    var searchController: UISearchController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        setUpSearchController()
        registerNibs()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpSearchController(){
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        searchResultsTableViewController = storyboard.instantiateViewControllerWithIdentifier("searchResultsTableViewController") as! SearchResultsTableViewController
        searchController = UISearchController(searchResultsController: searchResultsTableViewController)
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = true
        tableView.tableHeaderView = searchController.searchBar
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: .Top, animated: true)
        definesPresentationContext = true
    }
    
    func registerNibs(){
        let cellNib = UINib(nibName: StatesViewControllerCellType.CellWithImageView, bundle: nil)
        tableView.registerNib(cellNib , forCellReuseIdentifier: StatesViewControllerCellType.CellWithImageView)
    }
    
    func setUpTableView(){
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 49, right: 0)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 77, bottom: 0, right: 0)
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), atScrollPosition: UITableViewScrollPosition.Top, animated: false)
    }
    
    struct StatesViewControllerCellType {
        static let CellWithImageView = "CellWithImageView"
    }
}

//MARK: - TableViewDelegate

extension StateListViewController: UITableViewDelegate{
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 66
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if let cell = cell {
        performSegueWithIdentifier("showMapFromStatesList", sender: cell)
        }
    }
}

//MARK: - TableViewDataSource

extension StateListViewController: UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return states.numberOfStates()
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(StatesViewControllerCellType.CellWithImageView, forIndexPath: indexPath) as! CellWithImageView
        let element = states.element(forIndex: indexPath.row)
        cell.configureCell(forState: element)
        return cell
    }
}

extension StateListViewController: UISearchResultsUpdating{
    func updateSearchResultsForSearchController(searchController: UISearchController) {
       let list = states.stateNamesAndNicknames()
        filteredStateList = list.filter({
            element in
            return element.0.containsString(searchController.searchBar.text!)
        })
        searchResultsTableViewController.list = filteredStateList
        searchResultsTableViewController.tableView.reloadData()
    }
}










