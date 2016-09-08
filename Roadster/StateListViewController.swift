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

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        registerNibs()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func registerNibs(){
        let cellNib = UINib(nibName: StatesViewControllerCellType.CellWithImageView, bundle: nil)
        tableView.registerNib(cellNib , forCellReuseIdentifier: StatesViewControllerCellType.CellWithImageView)
    }
    
    func setUpTableView(){
        tableView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 49, right: 0)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 77, bottom: 0, right: 0)
    }
    
    struct StatesViewControllerCellType {
        static let CellWithImageView = "CellWithImageView"
    }
    
    func state(forIndexPath indexPath: NSIndexPath) -> (String, String){
        let list = states.statesNicknames()
        return list[indexPath.row]
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
        performSegueWithIdentifier("n", sender: cell)
        }
    }
    
}

//MARK: - TableViewDataSource

extension StateListViewController: UITableViewDataSource{
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 50
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let stateAndNickname = state(forIndexPath: indexPath)
        let cell = tableView.dequeueReusableCellWithIdentifier(StatesViewControllerCellType.CellWithImageView, forIndexPath: indexPath) as! CellWithImageView
        cell.configureCell(forState: stateAndNickname)
        return cell
    }
}

extension StateListViewController: UISearchDisplayDelegate{}









