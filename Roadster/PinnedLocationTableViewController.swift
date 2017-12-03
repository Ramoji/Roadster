//
//  PinnedLocationTableViewController.swift
//  Roadster
//
//  Created by EA JA on 9/14/17.
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit
import MapKit
import YelpAPI
import CoreLocation

class PinnedLocationsTableViewController: UITableViewController {
    
    var favoriteList: [Favorite] = []
    var frequentList: [Frequent] = []
    var locationList: [FavoriteLocation] = []
    var businessList: [HistoryYelpBusiness] = []
    var locationManager: CLLocationManager!
    var currentUserLocation: CLLocation!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        
        registerNibs()
        
        if CLLocationManager.authorizationStatus() == .restricted || CLLocationManager.authorizationStatus() == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        tableView.backgroundView = BlurredBackgroundView(frame: self.view.bounds, addBackgroundPic: true)
        
        

        
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        if CLLocationManager.authorizationStatus() == .denied{
            let deniedAuthorizationAlert = UIAlertController(title: "Limited Service", message: "Location services disabled. Please enable location services in settings", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            deniedAuthorizationAlert.addAction(alertAction)
            present(deniedAuthorizationAlert, animated: true, completion: nil)
        }
        
        startLocationManager()
        
        loadLists{
            self.tableView.reloadData()
        }
    }

    

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if favoriteList.count == 0 && frequentList.count == 0 && locationList.count == 0 && businessList.count == 0{
            return 1
        }
        
        return 4
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if favoriteList.count == 0 && frequentList.count == 0 && locationList.count == 0 && businessList.count == 0{
            return 1
        }
        
        if section == 0 {
            return favoriteList.count
        } else if section == 1{
            return frequentList.count
        } else if section == 2{
            return locationList.count
        } else {
            return businessList.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        
        if favoriteList.count == 0 && frequentList.count == 0 && locationList.count == 0 && businessList.count == 0{
            let cell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.NoRestStopsCell, for: indexPath) as! NoRestStopsCell
            cell.label.text = "No Saved Locations!"
            cell.backgroundColor = UIColor.clear
            return cell
        }
        
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.LocationsRestStopCell, for: indexPath) as! LocationsRestStopCell
            cell.configureCell(with: favoriteList[indexPath.row], currentUserLocation: currentUserLocation)
            return cell
            
        } else if indexPath.section == 1 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.LocationsRestStopCell, for: indexPath) as! LocationsRestStopCell
            cell.configureFrequentCell(with: frequentList[indexPath.row], currentUserLocation: currentUserLocation)
            return cell
            
        } else if indexPath.section == 2 {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.LocationsAddressCell, for: indexPath) as! LocationsAddressCell
            let mapItem = MKMapItem(placemark: locationList[indexPath.row].placemark)
            cell.configureCell(for: mapItem, and: currentUserLocation)
            return cell
            
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.LocationsBusinessCell, for: indexPath) as! LocationsBusinessCell
            cell.setUpHistoryCell(for: businessList[indexPath.row], and: currentUserLocation)
            return cell
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if favoriteList.count == 0 && frequentList.count == 0 && locationList.count == 0 && businessList.count == 0{
            return 74.0
        } else {
            return 84.0
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return getSectionHeaderView(with: "Favorite Rest Stops")
        } else if section == 1{
            return getSectionHeaderView(with: "Frequent Rest Stops")
        } else if section == 2 {
            return getSectionHeaderView(with: "Pinned Locations")
        } else {
            return getSectionHeaderView(with: "Favorite Businesses")
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height: CGFloat = 0
        switch section {
        case 0:
            if favoriteList.count == 0 {
                height = 0
            } else {
                height = 20
            }
            
        case 1:
            if frequentList.count == 0 {
                height = 0
            } else {
                height = 20
            }
            
        case 2:
            if locationList.count == 0 {
                height = 0
            } else {
                height = 20
            }
            
        case 3:
            if businessList.count == 0 {
                height = 0
            } else {
                height = 20
            }
        default:
            print("")
        }
        
        return height
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?){
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        print("*** Section is: \(indexPath.section)")
        switch indexPath.section {
        case 0:
            
            deleteTable(item: favoriteList[indexPath.row])
            break
        case 1:
            deleteTable(item: frequentList[indexPath.row])
            break
        case 2:
            deleteTable(item: locationList[indexPath.row])
            break
        case 3:
            deleteTable(item: businessList[indexPath.row])
            break
        default:
            print("")
        }
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        switch indexPath.section{
        case 0:
            performSegue(withIdentifier: "pinnedFavoriteStaticDetailTableViewControllerSegue", sender: cell)
            break
        case 1:
            performSegue(withIdentifier: "PinnedFrequentStaticDetailTableViewControllerSegue", sender: cell)
            break
        case 2:
            performSegue(withIdentifier: "PinnedAddressViewControllerSegue", sender: cell)
            break
        case 3:
            performSegue(withIdentifier: "BusinessDetailViewControllerSeque", sender: cell)
            break
        default:
            print("")
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
  
   
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPath(for: cell)!
        switch segue.identifier! {
        case "pinnedFavoriteStaticDetailTableViewControllerSegue":
            
                let element = favoriteList[indexPath.row] 
                let pinnedLocationTableViewController = segue.destination as! PinnedFavoriteStaticDetailTableViewController
                pinnedLocationTableViewController.favorite = element
                pinnedLocationTableViewController.fullStateName = States.getFullStateName(for: element.state)
                
            break
            
        case "PinnedFrequentStaticDetailTableViewControllerSegue":
            
            let element = frequentList[indexPath.row]
            let pinnedFrequentStaticDetailTableViewControllerSegue = segue.destination as! PinnedFrequentStaticDetailTableViewController
            pinnedFrequentStaticDetailTableViewControllerSegue.frequent = element
            pinnedFrequentStaticDetailTableViewControllerSegue.fullStateName = States.getFullStateName(for: element.state)
            
            break
            
        case "PinnedAddressViewControllerSegue":
            
            let pinnedAddressViewController = segue.destination as! PinnedAddressViewController
            let mapItem = MKMapItem(placemark: locationList[indexPath.row].placemark)
            pinnedAddressViewController.mapItem = mapItem
            pinnedAddressViewController.currentUserLocation = currentUserLocation
            
            break
            
        case "BusinessDetailViewControllerSeque":
            
            let businessDetailViewController = segue.destination as! BusinessDetailViewController
            businessDetailViewController.businessID = businessList[indexPath.row].businessIdentifier
            businessDetailViewController.currentUserLocation = currentUserLocation
            
            break
            
        default:
            print("")
        }
    }
    
    
    
    
    func getSectionHeaderView(with title: String) -> UIView{
        let sectionHeaderView = UILabel()
        let headerAttributedString = NSAttributedString(string: title.uppercased(), attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor.white])
        sectionHeaderView.attributedText = headerAttributedString
        sectionHeaderView.sizeToFit()
        let headerViewContainer = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: sectionHeaderView.bounds.height + 10))
        sectionHeaderView.translatesAutoresizingMaskIntoConstraints = false
        headerViewContainer.addSubview(sectionHeaderView)
        let headerViewTopConstraint = sectionHeaderView.centerYAnchor.constraint(equalTo: headerViewContainer.centerYAnchor)
        let headerViewLeadingConstraint = sectionHeaderView.leadingAnchor.constraint(equalTo: headerViewContainer.leadingAnchor, constant: 18.0)
        let headerViewWidthConstraint = sectionHeaderView.widthAnchor.constraint(equalToConstant: sectionHeaderView.bounds.width)
        let headerViewHeightConstraint = sectionHeaderView.heightAnchor.constraint(equalToConstant: sectionHeaderView.bounds.height)
        NSLayoutConstraint.activate([headerViewTopConstraint, headerViewLeadingConstraint, headerViewWidthConstraint, headerViewHeightConstraint])
        headerViewContainer.backgroundColor = UIColor.lightGray
//        let seperator = UIView()
//        seperator.backgroundColor = UIColor.lightGray
//        headerViewContainer.addSubview(seperator)
//        seperator.translatesAutoresizingMaskIntoConstraints = false
//        let seperatorBottomConstraint = seperator.bottomAnchor.constraint(equalTo: headerViewContainer.bottomAnchor)
//        let seperatorLeadingConstraint = seperator.leadingAnchor.constraint(equalTo: headerViewContainer.leadingAnchor, constant: 15.0)
//        let seperatorHeightConstraint = seperator.heightAnchor.constraint(equalToConstant: 0.5)
//        let seperatorWidthConstraint = seperator.widthAnchor.constraint(equalToConstant: headerViewContainer.bounds.width - 15.0)
//        
//        NSLayoutConstraint.activate([seperatorBottomConstraint, seperatorLeadingConstraint, seperatorHeightConstraint, seperatorWidthConstraint])
        
        return headerViewContainer
    }
    
    
    

    func loadLists(completionHandler: () -> ()){
        favoriteList = CoreDataHelper.shared.getFavorites()
        print("*** favorite list count is: \(favoriteList.count)")
        frequentList = CoreDataHelper.shared.getFrequents()
        print("*** frequent list count is: \(frequentList.count)")
        locationList = getFavoriteLocationsList()
        businessList = getFavoriteBusinessList()
        completionHandler()
    }
    
    func getFavoriteLocationsList() -> [FavoriteLocation]{
        
        guard let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return []}
        let favoriteLocationsPath = documentsDir.appendingPathComponent(KeyedArchiverKeys.favoriteLocationsListKey).path
        guard FileManager.default.fileExists(atPath: favoriteLocationsPath) else {return []}
        return NSKeyedUnarchiver.unarchiveObject(withFile: favoriteLocationsPath) as! [FavoriteLocation]
    }
    
    func getFavoriteBusinessList() -> [HistoryYelpBusiness]{
        
        guard let documentDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return []
        }
        
        let favoriteBusinessesPath = documentDir.appendingPathComponent(KeyedArchiverKeys.favoriteBusinessesListKey).path
        guard FileManager.default.fileExists(atPath: favoriteBusinessesPath) else {
            return []
        }
        
        return NSKeyedUnarchiver.unarchiveObject(withFile: favoriteBusinessesPath) as! [HistoryYelpBusiness]
    }
    
    
    func registerNibs(){
        var nib = UINib(nibName: CustomCellTypeIdentifiers.LocationsRestStopCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CustomCellTypeIdentifiers.LocationsRestStopCell)
        nib = UINib(nibName: CustomCellTypeIdentifiers.LocationsAddressCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CustomCellTypeIdentifiers.LocationsAddressCell)
        nib = UINib(nibName: CustomCellTypeIdentifiers.LocationsBusinessCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CustomCellTypeIdentifiers.LocationsBusinessCell)
        nib = UINib(nibName: CustomCellTypeIdentifiers.NoRestStopsCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CustomCellTypeIdentifiers.NoRestStopsCell)
    }
    
    func startLocationManager(){
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationManager(){
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
    }
    
    func deleteTable(item: AnyObject){
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        switch item {
        case is Favorite:
            let favorite = item as! Favorite
            print("*** Favorite to delete latitude: \(favorite.latitude)")
            print("*** Favorite to delete longitude: \(favorite.longitude)")
            CoreDataHelper.shared.deleteFavorite(latitude: favorite.latitude, longitude: favorite.longitude)
            
            break
        case is Frequent:
            
            let frequent = item as! Frequent
            CoreDataHelper.shared.deleteFrequent(latitude: frequent.latitude, longitude: frequent.longitude)
            break
            
        case is FavoriteLocation:
            
            let location = item as! FavoriteLocation
            for (index, element) in locationList.enumerated(){
                if location.placemark.coordinate.latitude == element.placemark.coordinate.latitude && location.placemark.coordinate.longitude == element.placemark.coordinate.longitude{
                    locationList.remove(at: index)
                }
            }
            
            let locationListPath = documentsDirectory.appendingPathComponent(KeyedArchiverKeys.favoriteLocationsListKey).path
            NSKeyedArchiver.archiveRootObject(locationList, toFile: locationListPath)
            
            break
        case is HistoryYelpBusiness:
            
            let business = item as! HistoryYelpBusiness
            for (index, element) in businessList.enumerated(){
                if business.businessIdentifier == element.businessIdentifier{
                    businessList.remove(at: index)
                }
            }
            
            let businessListPath = documentsDirectory.appendingPathComponent(KeyedArchiverKeys.favoriteBusinessesListKey).path
            NSKeyedArchiver.archiveRootObject(businessList, toFile: businessListPath)
            
            break
        default:
            print("*** In delete table view item switch default")
        }
        
        loadLists {
            self.tableView.reloadData()
        }
    }

}

extension PinnedLocationsTableViewController: CLLocationManagerDelegate{
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else {
            return
        }
        
        print("*** In location manager!")
        
        if newLocation.timestamp.timeIntervalSinceNow < -5 {
            stopLocationManager()
        }
        
        if newLocation.horizontalAccuracy < 0 {
            return
        }
        
        currentUserLocation = newLocation
        tableView.reloadData()
        
        print("*** newLocation horizonal accuracy is: \(newLocation.horizontalAccuracy)")
        print("*** location manager horizonal accuracy is: \(locationManager.desiredAccuracy)")
        if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy{
            print("*** Done with location manager!")
            stopLocationManager()
        }
    }
    
}
