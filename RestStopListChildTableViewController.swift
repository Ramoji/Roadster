//
//  RestStopTableViewController.swift
//  Roadster
//
//  Created by A Ja on 10/15/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

protocol RestStopListChildTableViewControllerDelegate: class{
    func restStopListTable(_ childTableViewController: RestStopListChildTableViewController, didPickRestStop restStop: USRestStop)
    func restStopListTable(_ childTableViewController: RestStopListChildTableViewController, didFindUserLocation: CLLocation)
    func restStopListTableDidNotFindLocation(_ childTableViewController: RestStopListChildTableViewController)
}

import UIKit
import CoreData
import CoreLocation

class RestStopListChildTableViewController: UIViewController {
    
    
    weak var delegate: RestStopListChildTableViewControllerDelegate?
    @IBOutlet weak var tableView: UITableView!
    var blurredBackgroundView = BlurredBackgroundView(frame: CGRect.zero, addBackgroundPic: true)
    var restStopList: [USRestStop] = [USRestStop]()
    var chosenCell: UITableViewCell!
    var chosenRestStop: USRestStop!
    var shouldSelectFirstRow = true
    var fullStateName: String!
    var bound = ""
    var locationManager: CLLocationManager = CLLocationManager()
    var userCurrentLocation: CLLocation!
    var location: CLLocation!
    var lastLocationError: NSError!
    var restStopDistanceFromUser: [Int] = [Int]()
    var isViewFirstLoad = true
    
    
   

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getUserLocation()
        registerNibs()
        setUpTableView()
    }
    
    override func loadView() {
        super.loadView()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if shouldSelectFirstRow{
            selectFirstRow()
            shouldSelectFirstRow = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let _ = chosenCell {
            selectCurrentRow()
        }
        
        if isViewFirstLoad {
            isViewFirstLoad = false
        } else {
            getUserLocation()
        }

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("***Receiving Memory Warning RestStopListChildTableViewController!")
    }
    
    func setUpTableView(){
        
        tableView.backgroundView = blurredBackgroundView
        tableView.separatorColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
        
    }
    
    func selectFirstRow(){
        let indexPath = IndexPath(row: 0, section: 0)
        if !restStopList.isEmpty {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
            delegate?.restStopListTable(self, didPickRestStop: restStopList[0])
            tableView.scrollToRow(at: indexPath, at: .top, animated: false)
            chosenCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        }
    }
    
    func selectCurrentRow(){
        tableView.selectRow(at: tableView.indexPath(for: chosenCell), animated: true, scrollPosition: UITableViewScrollPosition.middle)
    }
    
    func registerNibs(){
        var nib = UINib(nibName: CustomCellTypeIdentifiers.CellWithImageView, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CustomCellTypeIdentifiers.CellWithImageView)
        nib = UINib(nibName: CustomCellTypeIdentifiers.NoRestStopsCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CustomCellTypeIdentifiers.NoRestStopsCell)
        nib = UINib(nibName: CustomCellTypeIdentifiers.RestStopCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CustomCellTypeIdentifiers.RestStopCell)
        nib = UINib(nibName: CustomCellTypeIdentifiers.FirstRestStopCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CustomCellTypeIdentifiers.FirstRestStopCell)
        nib = UINib(nibName: CustomCellTypeIdentifiers.EndRestStopCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CustomCellTypeIdentifiers.EndRestStopCell)
        nib = UINib(nibName: CustomCellTypeIdentifiers.OnlyOneRestStopCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CustomCellTypeIdentifiers.OnlyOneRestStopCell)
    }
    
    func getTapGR() -> UITapGestureRecognizer{
        let tapGR = UITapGestureRecognizer(target: self, action: #selector(didDoubleTap))
        tapGR.numberOfTapsRequired = 2
        tapGR.numberOfTouchesRequired = 1
        return tapGR
    }
    
    func didDoubleTap(){
        performSegue(withIdentifier: "showStaticDetailTable", sender: chosenCell)
    }
    
    func addDoubleTapGR(to cell: UITableViewCell){
        if let gestureRecognizers = cell.gestureRecognizers{
            if !gestureRecognizers.isEmpty{
                cell.removeGestureRecognizer(cell.gestureRecognizers![0])
            }
        }
        let tapGR = getTapGR()
        cell.addGestureRecognizer(tapGR)
    }
    
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showStaticDetailTable"{
            let staticDetailTableViewController = segue.destination as! StaticDetailTableViewController
            staticDetailTableViewController.restStop = chosenRestStop
            staticDetailTableViewController.fullStateName = fullStateName
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        view.addShadow(withCornerRadius: 0)
    }
    
    func mapViewDidChangeBound(){
        getUserLocation()
        tableView.reloadData()
        selectFirstRow()
    }
    
    deinit{
        print("RestStopListChildTableViewController got deallocated!")
    }
}

//MARK: - Tableview delegate and Datasource
extension RestStopListChildTableViewController: UITableViewDataSource, UITableViewDelegate{
    
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if restStopList.isEmpty {
            return 1
        } else {
            return restStopList.count
        }
    }
    
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if restStopList.isEmpty {
            let cell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.NoRestStopsCell, for: indexPath) as! NoRestStopsCell
            if let gestureRecognizers = cell.gestureRecognizers{
                if !gestureRecognizers.isEmpty{
                    cell.removeGestureRecognizer(cell.gestureRecognizers![0])
                }
            }
            cell.backgroundColor = UIColor.clear
            cell.accessoryType = .none
            return cell
        } else {
            var cellToReturn = UITableViewCell(style: .default, reuseIdentifier: "cell")
            switch indexPath.row{
            case 0:
                
                if restStopList.count == 1 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.OnlyOneRestStopCell) as! OnlyOneRestStopCell
                    if let _ = userCurrentLocation {
                        cell.configureCell(with: restStopDistanceFromUser[indexPath.row], restStop: restStopList[indexPath.row])
                        addDoubleTapGR(to: cell)
                    }
                    return cell
                } else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.FirstRestStopCell, for: indexPath) as! FirstRestStopCell
                    if let _ = userCurrentLocation {
                        cell.configureCell(with: restStopDistanceFromUser[indexPath.row], restStop: restStopList[indexPath.row])
                        addDoubleTapGR(to: cell)
                    }
                    cellToReturn = cell
                }
                
                
            case restStopList.count - 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.EndRestStopCell, for: indexPath) as! EndRestStopCell
                if let _ = userCurrentLocation{
                    cell.configureCell(with: restStopDistanceFromUser[indexPath.row], restStop: restStopList[indexPath.row])
                    addDoubleTapGR(to: cell)
                }
                cellToReturn = cell
                
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.RestStopCell, for: indexPath) as! RestStopCell
                if let _ = userCurrentLocation{
                    cell.configureCell(with: restStopDistanceFromUser[indexPath.row], restStop: restStopList[indexPath.row])
                    addDoubleTapGR(to: cell)
                }
                cellToReturn = cell
                
            }
            
            return cellToReturn
        }
    }
    
     func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !restStopList.isEmpty{
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .middle)
            delegate?.restStopListTable(self, didPickRestStop: restStopList[indexPath.row])
            if indexPath.row == 0 && tableView.numberOfRows(inSection: 0) == 1 {
                chosenCell = tableView.cellForRow(at: indexPath) as! OnlyOneRestStopCell
            } else if indexPath.row == 0 {
                chosenCell = tableView.cellForRow(at: indexPath) as! FirstRestStopCell
            } else if indexPath.row == restStopList.count - 1{
                chosenCell = tableView.cellForRow(at: indexPath) as! EndRestStopCell
            } else {
            chosenCell = tableView.cellForRow(at: indexPath) as! RestStopCell
            }
            chosenRestStop = restStopList[indexPath.row]
        } else {
            tableView.deselectRow(at: indexPath, animated: false)
        }
    }
    
     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    
}


extension RestStopListChildTableViewController: CLLocationManagerDelegate{
    
    func getUserLocation(){
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .denied || authStatus == .restricted{
            showLocationServicesDeniedAlert()
        }
        startLocationManager()
    }
    
    func startLocationManager(){
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationManager(){
        location = nil
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
    }
    
    func showLocationServicesDeniedAlert(){
        let alert = UIAlertController(title: "Location Services Disabled", message: "Location Services is disabled. Please enable location servises for this app in Settings.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let newLocation = locations.last
        if let newLocation = newLocation{
            if newLocation.timestamp.timeIntervalSinceNow < -5 {
                return
            }
            
            
            if newLocation.horizontalAccuracy < 0 {
                return
            }
            
            if location == nil || location.horizontalAccuracy > newLocation.horizontalAccuracy{
                location = newLocation
                itHasBeenTooLong(location: location, newLocation: newLocation)
                lastLocationError = nil
                if location.horizontalAccuracy <= locationManager.desiredAccuracy{
                    userCurrentLocation = location
                    getRestStopDistanceFromUser()
                    delegate?.restStopListTable(self, didFindUserLocation: userCurrentLocation)
                    stopLocationManager()
                    tableView.reloadData()
                }
            }
        }
    }
    
    func itHasBeenTooLong(location: CLLocation, newLocation: CLLocation){
        let distance = newLocation.distance(from: location)
        if distance < 1 {
            if newLocation.timestamp.timeIntervalSince(location.timestamp) > 10 {
                stopLocationManager()
                delegate?.restStopListTableDidNotFindLocation(self)
            }
        }
    }
    
    func getRestStopDistanceFromUser(){
        restStopDistanceFromUser = []
        if !restStopList.isEmpty {
            for restStop in restStopList{
                let restStopLocation = CLLocation(latitude: restStop.latitude, longitude: restStop.longitude)
                let distance: Int = Int(userCurrentLocation.distance(from: restStopLocation) / 1609.34)
                restStopDistanceFromUser.append(distance)
            }
        }
    }
}






