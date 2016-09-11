//
//  SearchResultsTableViewController.swift
//  Roadster
//
//  Created by A Ja on 9/10/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

import UIKit

class SearchResultsTableViewController: UITableViewController {
    
    var list: [(String, String)]!

    override func viewDidLoad() {
        super.viewDidLoad()
        registerNibs()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func registerNibs(){
        let nib = UINib(nibName: SearchResultsViewControllerCellType.CellWithImageView, bundle: nil)
        tableView.registerNib(nib, forCellReuseIdentifier: SearchResultsViewControllerCellType.CellWithImageView)
    }
    
    struct SearchResultsViewControllerCellType {
        static let CellWithImageView = "CellWithImageView"
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(SearchResultsViewControllerCellType.CellWithImageView, forIndexPath: indexPath) as! CellWithImageView
        if let list = list{
            let element = list[indexPath.row]
            cell.configureCell(forState: element)
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 66
    }
    
    //MARK: - Table view delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if let cell = cell {
            performSegueWithIdentifier("showMapFromSearchResultsList", sender: cell)
        }
    }
}
