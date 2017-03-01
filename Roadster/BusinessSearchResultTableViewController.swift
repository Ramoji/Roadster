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

protocol BusinessSearchResultTableViewControllerDelegate: class {
    func businessSearchResultTableViewStartedGettingBusiness()
    func businessSearchResultTableViewStopedGettingBusiness(with searchResultList: [AnyObject])
}

class BusinessSearchResultTableViewController: UIViewController{

    @IBOutlet weak var tableView: UITableView!
    var panGestureRecognizer: UIPanGestureRecognizer!
    var delegate: BusinessSearchResultTableViewControllerDelegate?
    var ylpClient: YLPClient!
    var businessResults: [YLPBusiness] = []
    var restStopResults: [USRestStop] = []
    var managedObjectContext: NSManagedObjectContext!
    var globalQueue = DispatchQueue.global(qos: .userInitiated)
    var mainQueue = DispatchQueue.main
    var panGR: UIPanGestureRecognizer!
    var appWindow: UIWindow!
    var headerView: UIView!
    
    
   
   
    override func viewDidLoad() {
        super.viewDidLoad()
        let blurredBackgroundView = BlurredBackgroundView(frame: self.view.bounds, addBackgroundPic: true)
        tableView.backgroundView = blurredBackgroundView
        registerNibs()
        setUpHeaderView()
        setUpTableView()
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
        
        headerView = UIView()
        view.addSubview(headerView)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = headerView.topAnchor.constraint(equalTo: topLayoutGuide.topAnchor)
        let heightConstraint = headerView.heightAnchor.constraint(equalToConstant: 50)
        let leadingConstraint = headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let trailingConstraint = headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        NSLayoutConstraint.activate([topConstraint, heightConstraint, leadingConstraint, trailingConstraint])
        
        let grabView = UIView()
        let searchLabel = UILabel()
        let separator = UIView()
        
        
        headerView.addSubview(searchLabel)
        headerView.addSubview(separator)
        headerView.addSubview(grabView)
        
        
        grabView.backgroundColor = tableView.separatorColor
        grabView.layer.cornerRadius = 2.5
        grabView.translatesAutoresizingMaskIntoConstraints = false
        let grabViewWidthConstraint = grabView.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 0.10)
        let grabViewHeightConstraint = grabView.heightAnchor.constraint(equalToConstant: 5)
        let grabViewTopConstraint = grabView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 5)
        let grabViewHorizonalConstraint = grabView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor)
        NSLayoutConstraint.activate([grabViewWidthConstraint, grabViewHeightConstraint, grabViewTopConstraint,grabViewHorizonalConstraint])
        
        
        searchLabel.textAlignment = .center
        let searchLabelFont = UIFont.systemFont(ofSize: 15)
        let searchLabelAttributedText = NSAttributedString(string: "Search Results", attributes: [NSFontAttributeName: searchLabelFont])
        searchLabel.attributedText = searchLabelAttributedText
        searchLabel.translatesAutoresizingMaskIntoConstraints = false
        let searchLabelTrailingConstraint = searchLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor)
        let searchLabelLeadingConstraint = searchLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor)
        let searchLabelHeightConstraint = searchLabel.heightAnchor.constraint(equalToConstant: 34.0)
        let searchLabelTopConstraint = searchLabel.topAnchor.constraint(equalTo: grabView.bottomAnchor)
        NSLayoutConstraint.activate([searchLabelTrailingConstraint, searchLabelLeadingConstraint, searchLabelHeightConstraint, searchLabelTopConstraint])
    
        
        separator.backgroundColor = tableView.separatorColor
        separator.translatesAutoresizingMaskIntoConstraints = false
        let seperatorBottomConstraint = separator.topAnchor.constraint(equalTo: tableView.topAnchor)
        let seperatorTrailingConstraint = separator.trailingAnchor.constraint(equalTo: headerView.trailingAnchor)
        let seperatorLeadingConstraint = separator.leadingAnchor.constraint(equalTo: headerView.leadingAnchor)
        let seperatorHeightConstraint = separator.heightAnchor.constraint(equalToConstant: 0.7)
        NSLayoutConstraint.activate([seperatorBottomConstraint, seperatorTrailingConstraint, seperatorLeadingConstraint, seperatorHeightConstraint])
    }
    
    func setUpTableView(){
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor)
        let leadingConstraint = tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let trailingConstraint = tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        let heightConstraint = tableView.heightAnchor.constraint(equalToConstant: 450)
        NSLayoutConstraint.activate([topConstraint, leadingConstraint, trailingConstraint, heightConstraint])
        tableView.clipsToBounds = true
        tableView.backgroundColor = UIColor.clear
    }
    
    func registerNibs(){
        let nib = UINib(nibName: CustomCellTypeIdentifiers.YelpTableViewCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CustomCellTypeIdentifiers.YelpTableViewCell)
    }
    
    func setUpView(){
        view.addShadow(withCornerRadius: 15.0)
    }
    
    
    func getBusinesses(withSearchTerm term: String, userCoordinates coordinate: CLLocationCoordinate2D){
        
        let ylpCoordinate = YLPCoordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let dimView = UIView(frame: view.bounds)
        dimView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.addSubview(dimView)
        
        view.layoutIfNeeded()
        
        let maskPath = UIBezierPath(roundedRect: dimView.bounds, byRoundingCorners: [UIRectCorner.topLeft, UIRectCorner.topRight], cornerRadii: CGSize(width: 15.0, height: 15.0))
        let maskLayer = CAShapeLayer()
        maskLayer.path = maskPath.cgPath
        dimView.layer.mask = maskLayer
        
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

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        headerView.removeFromSuperview()
        setUpHeaderView()
        setUpTableView()
        setUpView()
    }
    
    
    
    
}

extension BusinessSearchResultTableViewController: UITableViewDataSource{
    
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
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.YelpTableViewCell, for: indexPath) as! YelpTableViewCell
        if restStopResults.count != 0 {
            cell.textLabel?.text = restStopResults[indexPath.row].stopName
        } else {
            cell.setUp(for: businessResults[indexPath.row])
        }
        cell.backgroundColor = UIColor.clear
        return cell
    }
    
}

extension BusinessSearchResultTableViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let topViewUpperConstraint: NSLayoutConstraint!
        
        for constraint in view.superview!.constraints{
            print("Constraint identifier is: \(constraint.identifier)")
        }
        
    }
    
 
}


