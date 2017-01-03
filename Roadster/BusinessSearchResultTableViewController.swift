//
//  BusinessSearchResultTableViewController.swift
//  Roadster
//
//  Created by A Ja on 12/19/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

import UIKit
import YelpAPI
import CoreLocation
import CoreData
import Dispatch

protocol BusinessSearchResultTableViewControllerProtocol: class {
    func businessSearchResultTableViewStartedGettingBusiness()
    func businessSearchResultTableViewStopedGettingBusiness(with searchResultList: [AnyObject])
}

class BusinessSearchResultTableViewController: UIViewController{

    @IBOutlet weak var tableView: UITableView!
    var panGestureRecognizer: UIPanGestureRecognizer!
    var delegate: BusinessSearchResultTableViewControllerProtocol?
    var ylpClient: YLPClient!
    var businessResults: [YLPBusiness] = []
    var restStopResults: [USRestStop] = []
    var managedObjectContext: NSManagedObjectContext!
    var globalQueue = DispatchQueue.global(qos: .userInitiated)
    var mainQueue = DispatchQueue.main

    
    
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
    
    func getBusinesses(withSearchTerm term: String, userCoordinates coordinate: CLLocationCoordinate2D){
        
        let ylpCoordinate = YLPCoordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let dimView = UIView(frame: view.bounds)
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.addSubview(dimView)
        
        globalQueue.async {
            YLPClient.authorize(withAppId: "F9jmXf_AL6xCSqDUA0qrJA", secret: "5M4FdJC4hEGsl0XSXSETty7xluz8APQh05rP6HioeuNvoEcwllMKOCrHKFPvCFuh"){
                client, error in
                
                self.ylpClient = client
                
                client?.search(with: ylpCoordinate, term: term, limit: 20, offset: 0, sort: .distance){
                    search, error in
                    
                    if error != nil {
                        self.mainQueue.async {
                            let alert = UIAlertController(title: "Limited Service", message: "Unable to seatch for \(term)", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
                            dimView.removeFromSuperview()
                        }
                    } else {
                        self.mainQueue.async {
                            self.businessResults = (search?.businesses)!
                            self.restStopResults = []
                            self.delegate?.businessSearchResultTableViewStopedGettingBusiness(with: self.businessResults)
                            self.tableView.reloadData()
                            dimView.removeFromSuperview()
                        }
                    }
                }
            }
        }
    }
    
    func getNearByRestStops(maxCoordinate: CLLocationCoordinate2D, minCoordinate: CLLocationCoordinate2D){

        let fetchRequest: NSFetchRequest<USRestStop> = {
            let fetchRequest = NSFetchRequest<USRestStop>()
            fetchRequest.entity = USRestStop.entity()
            let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [NSPredicate(format: "latitude BETWEEN {%@, %@}", argumentArray: [minCoordinate.latitude, maxCoordinate.latitude]), NSPredicate(format: "longitude BETWEEN {%@, %@}", argumentArray: [minCoordinate.longitude, maxCoordinate.longitude])])
            fetchRequest.predicate = compoundPredicate
            fetchRequest.fetchBatchSize = 100
            fetchRequest.entity = USRestStop.entity()
            return fetchRequest
        }()
        
        do{
            restStopResults = try managedObjectContext.fetch(fetchRequest)
            businessResults = []
            
        }catch let error as NSError{
            print(error.debugDescription)
            fatalError("Fetching close restStops failed!")
        }
        
        delegate?.businessSearchResultTableViewStopedGettingBusiness(with: restStopResults)
        tableView.reloadData()
        
    }
    
    func getBusinessSearchResultTableViewControllerList(with searchTerm: String, userCurrentLocation: CLLocationCoordinate2D, maxCoordinate: CLLocationCoordinate2D, minCoordinate: CLLocationCoordinate2D){
        
        if searchTerm == "Rest Stops"{
            delegate?.businessSearchResultTableViewStartedGettingBusiness()
            getNearByRestStops(maxCoordinate: maxCoordinate, minCoordinate: minCoordinate)
        } else {
            delegate?.businessSearchResultTableViewStartedGettingBusiness()
            getBusinesses(withSearchTerm: searchTerm, userCoordinates: userCurrentLocation)
        }
    }

}

extension BusinessSearchResultTableViewController: UITableViewDelegate, UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if restStopResults.count != 0 {
            return restStopResults.count
        } else {
            return businessResults.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "cell")
        if restStopResults.count != 0 {
            cell.textLabel?.text = restStopResults[indexPath.row].stopName
        } else {
            cell.textLabel?.text = businessResults[indexPath.row].name
        }
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
}
