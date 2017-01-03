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
    var maxCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var minCoordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    var managedObjectContext: NSManagedObjectContext!
    var myRegion: MKCoordinateRegion!
    var startRegion: MKCoordinateRegion!
    var fetchRequest: NSFetchRequest<NSFetchRequestResult>!
    let concurrentQueue = DispatchQueue(label: "myQueue", attributes: .concurrent)
    var busiPickerView: UIPickerView =  UIPickerView()
    var client: YLPClient!
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
        if let _ = userCurrentCLLocation{
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
        maxCoordinate.latitude = myRegion.center.latitude + 0.5 * startRegion.span.latitudeDelta
        minCoordinate.latitude = myRegion.center.latitude - 0.5 * startRegion.span.latitudeDelta
        maxCoordinate.longitude = myRegion.center.longitude + 0.5 * startRegion.span.longitudeDelta
        minCoordinate.longitude = myRegion.center.longitude - 0.5 * startRegion.span.longitudeDelta
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
    
   
    
    func addChildTableViewController(){
        
        childController = storyboard?.instantiateViewController(withIdentifier: "BusinessSearchResultTableViewController") as! BusinessSearchResultTableViewController
        childController.delegate = self
        childController.managedObjectContext = managedObjectContext
        let childControllerHeight = view.bounds.height - ((tabBarController?.tabBar.bounds.height)! + (navigationController?.navigationBar.bounds.height)! * 2)
        childController.view.frame = CGRect(x: 0, y: 200, width: view.bounds.size.width, height: childControllerHeight)
        childController.view.layer.cornerRadius = 15
        childController.view.clipsToBounds = true
        view.addSubview(childController.view)
        self.addChildViewController(childController)
        childController.didMove(toParentViewController: self)
        childController.view.addShadow(withCornerRadius: 15)
        
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
    
    func setUpMapView(with list: [AnyObject]){
        
        if list is [USRestStop]{
            mapView.showsCompass = true
            mapView.showsScale = true
            mapView.setRegion(myRegion, animated: true)
            mapView.addAnnotations(list as! [USRestStop])
            mapView.showsUserLocation = true
        }
    }
    
}
extension NearByViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
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
                    getMinMaxLatLong()
                    childController.getBusinessSearchResultTableViewControllerList(with: dropDownTextField.text!, userCurrentLocation: userCurrentLocation, maxCoordinate: maxCoordinate, minCoordinate: minCoordinate)
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


extension NearByViewController: BusinessSearchResultTableViewControllerProtocol{
    
    func businessSearchResultTableViewStartedGettingBusiness() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
    }
    
    func businessSearchResultTableViewStopedGettingBusiness(with searchResultList: [AnyObject]){
        // Also add a condition for when list is not an array of USRestStops.
        setUpMapView(with: searchResultList)
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        
        
    }
    
}


