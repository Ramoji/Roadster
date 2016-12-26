//
//  BusinessSearchResultTableViewController.swift
//  Roadster
//
//  Created by A Ja on 12/19/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

import UIKit
import YelpAPI

class BusinessSearchResultTableViewController: UIViewController{
    
    var businesses: [YLPBusiness] = []
    var restStops: [USRestStop] = []
    @IBOutlet weak var tableView: UITableView!
    var panGestureRecognizer: UIPanGestureRecognizer!
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpHeaderView()
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func loadView() {
        super.loadView()
    }
    
    //MARK: - SetUps
    func setUpHeaderView(){
        let headerViewFrame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 50)
        let headerView = UIView(frame: headerViewFrame)
            headerView.backgroundColor = UIColor.clear
        let grabViewFrame = CGRect(x: view.bounds.size.width / 2 - 20, y: 5, width: 40, height: 5)
        let grabView = UIView(frame: grabViewFrame)
            grabView.backgroundColor = tableView.separatorColor
            grabView.layer.cornerRadius = 2.5
        let separatorFrame = CGRect(x: 0, y: 49, width: view.bounds.size.width, height: 0.7)
        let separator = UIView(frame: separatorFrame)
            separator.backgroundColor = tableView.separatorColor
        let searchLabelFrame = CGRect(x: 0, y: 10, width: view.bounds.size.width, height: 34)
        let searchLabel = UILabel(frame: searchLabelFrame)
            searchLabel.textAlignment = .center
        let searchLabelFont = UIFont.systemFont(ofSize: 15)
        let searchLabelAttributedText = NSAttributedString(string: "Search Results", attributes: [NSFontAttributeName: searchLabelFont])
        searchLabel.attributedText = searchLabelAttributedText
        headerView.addSubview(searchLabel)
        headerView.addSubview(separator)
        headerView.addSubview(grabView)
        view.addSubview(headerView)
    }
    
    
    func addPanGestureRecognizer(toView: UIView){
        
    }

}

extension BusinessSearchResultTableViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return businesses.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = businesses[indexPath.row].name
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
}
