//
//  NearByViewController.swift
//  Roadster
//
//  Created by A Ja on 10/14/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Dispatch
import CoreData
import YelpAPI
import QuartzCore

protocol NearByViewControllerDelegate: class {
    func nearByViewController(_ controller: NearByViewController, didFinishPicking item: USRestStop)
}

class NearByViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var locationManger: CLLocationManager!
    var lastLocationError: NSError!
    var location: CLLocation!
    var locationManagerUpdating: Bool!
    var userCurrentLocation: CLLocationCoordinate2D!
    var userCurrentCLLocation: CLLocation!
    var maxLat: Double!
    var minLat: Double!
    var maxLong: Double!
    var minLong: Double!
    var nearByRestStops: [USRestStop]!
    var managedObjectContext: NSManagedObjectContext!
    var myRegion: MKCoordinateRegion!
    var startRegion: MKCoordinateRegion!
    var fetchRequest: NSFetchRequest<NSFetchRequestResult>!
    let concurrentQueue = DispatchQueue(label: "myQueue", attributes: .concurrent)
    var busiPickerView: UIPickerView =  UIPickerView()
    var client: YLPClient!
    var businessResults: [YLPBusiness] = [YLPBusiness]()
    var businesses = ["Rest Stops", "Hospitals", "Gas Stations", "Restaurants", "Grocery", "Veterinarian"]
    var childController: BusinessSearchResultTableViewController!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var dropDownTextField: NoCursorTextField!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerUserDefaults()
        mapView.isHidden = true
        getUserCurrentLocation()
        setUpSegmentedControl()
        setUpBusiPickerView()
        setUpDropDownTextField()
    }

    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getUserCurrentLocation()
        if let userCurrentCLLocation = userCurrentCLLocation{
            getUserCurrentLocation()
        }
    }
    
    override func loadView() {
        super.loadView()
        addChildTableViewController()
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("*** Receiving Memory Warning from NearByViewController!")
    }
    
    func setUpMapView(){
        mapView.showsCompass = true
        mapView.showsScale = true
        mapView.setRegion(myRegion, animated: true)
        mapView.addAnnotations(nearByRestStops)
        mapView.showsUserLocation = true
    }
    
    func performFetch(){
        
        fetchRequest = {
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
            fetchRequest.entity = USRestStop.entity()
            let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [NSPredicate(format: "latitude BETWEEN {%@, %@}", argumentArray: [minLat, maxLat]), NSPredicate(format: "longitude BETWEEN {%@, %@}", argumentArray: [minLong, maxLong])])
            fetchRequest.predicate = compoundPredicate
            fetchRequest.fetchBatchSize = 100
            fetchRequest.entity = USRestStop.entity()
            return fetchRequest
        }()
        
        do{
            nearByRestStops = try managedObjectContext.fetch(fetchRequest) as! [USRestStop]
    
        }catch let error as NSError{
            print(error.debugDescription)
            fatalError("Fetching close restStops failed!")
        }
    }
    
    
    func getUserCurrentLocation(){
        let authStatus = CLLocationManager.authorizationStatus()
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        startLocationManager()
    }
    
    func startLocationManager(){
        if CLLocationManager.locationServicesEnabled(){
            activityIndicator.isHidden = false
            activityIndicator.startAnimating()
            locationManagerUpdating = true
            locationManger.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locationManger.delegate = self
            locationManger.startUpdatingLocation()
        }
    }
    
    func stopLocationManager(){
        location = nil
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
        locationManger.stopUpdatingLocation()
        locationManger.delegate = nil
        locationManagerUpdating = false
        lastLocationError = nil
    }
    
    func showLocationServicesDeniedAlert(){
        let alert = UIAlertController(title: "Location Services Disabled", message: "Location Services is disabled. Please enable location servises for this app in Settings.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }
    
    func getMinMaxLatLong(){
        myRegion = MKCoordinateRegionMakeWithDistance(userCurrentLocation, 80467, 80467)
        startRegion = MKCoordinateRegionMakeWithDistance(userCurrentLocation, 80467, 80467)
        maxLat = myRegion.center.latitude + 0.5 * startRegion.span.latitudeDelta
        print("Max Lat:")
        print(maxLat)
        minLat = myRegion.center.latitude - 0.5 * startRegion.span.latitudeDelta
        print("Min Lat:")
        print(minLat)
        maxLong = myRegion.center.longitude + 0.5 * startRegion.span.longitudeDelta
        print("Max Long:")
        print(maxLong)
        minLong = myRegion.center.longitude - 0.5 * startRegion.span.longitudeDelta
        print("Min Long:")
        print(minLong)
    }
    
    func switchMapSatellite(){
        if segmentedControl.selectedSegmentIndex == 0 {
          mapView.mapType = .standard
        } else if segmentedControl.selectedSegmentIndex == 1 {
            mapView.mapType = .hybrid
        }
    }
    
    func registerUserDefaults(){
        UserDefaults.standard.register(defaults: ["pickedBusiness": "Rest Stops"])
    }
    
    func getBusinesses(withSearchTerm term: String, userCoordinates coordinate: CLLocationCoordinate2D){
        
        let ylpCoordinate = YLPCoordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
        YLPClient.authorize(withAppId: "F9jmXf_AL6xCSqDUA0qrJA", secret: "5M4FdJC4hEGsl0XSXSETty7xluz8APQh05rP6HioeuNvoEcwllMKOCrHKFPvCFuh"){
            client, error in
            
            self.client = client
            
            client?.search(with: ylpCoordinate, term: term, limit: 40, offset: 0, sort: .distance){
                search, error in
                
                if error != nil {
                    let alert = UIAlertController(title: "Limited Service", message: "Unable to seatch for \(term)", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.businessResults = (search?.businesses)!
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    
                    self.updateChildTableView(withList: self.businessResults)
                }
            }
        }
    }
    
    func addChildTableViewController(){
        
        childController = storyboard?.instantiateViewController(withIdentifier: "BusinessSearchResultTableViewController") as! BusinessSearchResultTableViewController
        let childControllerHeight = view.bounds.height - ((tabBarController?.tabBar.bounds.height)! + (navigationController?.navigationBar.bounds.height)! * 2)
        childController.view.frame = CGRect(x: 0, y: 200, width: view.bounds.size.width, height: childControllerHeight)
        childController.view.layer.cornerRadius = 15
        childController.view.clipsToBounds = true
        view.addSubview(childController.view)
        self.addChildViewController(childController)
        childController.didMove(toParentViewController: self)
        childController.view.addShadow(withCornerRadius: 15)
        
    }
    
    func updateChildTableView(withList list: [AnyObject]){
        
        childController.businesses = []
        childController.restStops = []
        
        if list is [USRestStop]{
            childController.restStops = list as! [USRestStop]
            childController.tableView.reloadData()
        } else {
            childController.businesses = list as! [YLPBusiness]
            childController.tableView.reloadData()
        }
        
    }
    
   
    
    // MARK: - *** Set Ups
    
    func setUpSegmentedControl(){
        segmentedControl.addTarget(self, action: #selector(switchMapSatellite), for: .valueChanged)
        segmentedControl.layer.backgroundColor = UIColor.white.cgColor
        
    }
    
    func setUpDropDownTextField(){
        dropDownTextField.inputView = busiPickerView
        dropDownTextField.text = UserDefaults.standard.string(forKey: "pickedBusiness")!
    }
    
    func setUpBusiPickerView(){
        busiPickerView.delegate = self
        busiPickerView.dataSource = self
        busiPickerView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        busiPickerView.addShadow(withCornerRadius: 0)
    }
    
}
extension NearByViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations.last)
        let newLocation = locations.last
        if let newLocation = newLocation {
            if newLocation.timestamp.timeIntervalSinceNow < -5 {
                return
            }
            if newLocation.horizontalAccuracy < 0 {
                return
            }
            
            if location == nil || location.horizontalAccuracy > newLocation.horizontalAccuracy{
                location = newLocation
                lastLocationError = nil
                if location.horizontalAccuracy <= locationManger.desiredAccuracy{
                    print("*** We are done with location manager!")
                    mapView.isHidden = false
                    userCurrentLocation = location.coordinate
                    userCurrentCLLocation = location
                    getBusinesses(withSearchTerm: dropDownTextField.text!, userCoordinates: userCurrentLocation)
                    getMinMaxLatLong()
                    performFetch()
                    setUpMapView()
                    updateChildTableView(withList: nearByRestStops)
                    stopLocationManager()
                }
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        lastLocationError = (error as NSError)
        stopLocationManager()
        location = nil
    }
    
   
}


extension NearByViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard annotation is USRestStop else {return nil}
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotation")
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
            annotationView?.canShowCallout = true
        }
        return annotationView
    }
    
}


extension NearByViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return businesses.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return businesses[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        dropDownTextField.text = businesses[row]
        dropDownTextField.resignFirstResponder()
        UserDefaults.standard.set(businesses[row] as String, forKey: "pickedBusiness")
        getUserCurrentLocation()
        
    }
}





