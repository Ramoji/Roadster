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
    var businessPickerView: UIPickerView =  UIPickerView()
    var client: YLPClient!
    var businesses = ["Rest Stops", "Hospitals", "Gas Stations", "Restaurants", "Grocery"]
    var childController: BusinessSearchResultTableViewController!
    var appWindow: UIWindow!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var dropDownTextField: NoCursorTextField!
    let verticalUpperLimit: CGFloat = -500
    var totalYTransaction: CGFloat = -500
    let verticalLowerLimit: CGFloat = -55
    var verticalMiddleLimit: CGFloat = -250
    var topViewUpperConstraint: NSLayoutConstraint!
    var heightConstraint: NSLayoutConstraint!
    var trailingConstraint: NSLayoutConstraint!
    var leadingConstraint: NSLayoutConstraint!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        registerUserDefaults()
        mapView.isHidden = true
        getUserCurrentLocation()
        setUpSegmentedControl()
        setUpBusiPickerView()
        setUpDropDownTextField()
        addChildTableViewController()
    }

    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let _ = userCurrentCLLocation{
            getUserCurrentLocation()
        }
    }
    
    override func loadView() {
        super.loadView()
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
        childController.appWindow = appWindow


        
        view.addSubview(childController.view)
        self.addChildViewController(childController)
        childController.didMove(toParentViewController: self)
        
        childController.view.translatesAutoresizingMaskIntoConstraints = false
        heightConstraint = childController.view.heightAnchor.constraint(equalToConstant: 800.0)
        leadingConstraint = childController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        trailingConstraint = childController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        topViewUpperConstraint = childController.view.topAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: -55)
        topViewUpperConstraint.identifier = "topViewUpperConstraint"
        
        NSLayoutConstraint.activate([heightConstraint, leadingConstraint, trailingConstraint, topViewUpperConstraint])
        addPanGestureTo(thisView: childController.view)
    }
    
    func addDimView(){
        if let _ = view.viewWithTag(1001){
            return
        } else {
            let dimView = UIView(frame: view.bounds)
            dimView.backgroundColor = UIColor.black
            dimView.alpha = 0.0
            dimView.tag = 1001
            view.insertSubview(dimView, at: 2)
            UIView.animate(withDuration: 0.3, animations: {
                dimView.alpha = 0.2
            })
        }
    }
    func removeDimView(){
        guard let dimView = view.viewWithTag(1001) else {return}
        dimView.removeFromSuperview()
        UIView.animate(withDuration: 0.3, animations: {
            //dimView.alpha = 0.0
        }){ (Bool) -> Void in
            dimView.removeFromSuperview()
        }
    }
    
    // MARK: - *** Set Ups
    
    func setUpSegmentedControl(){
        segmentedControl.addTarget(self, action: #selector(switchMapSatellite), for: .valueChanged)
        segmentedControl.layer.backgroundColor = UIColor.white.cgColor
        
    }
    
    func setUpDropDownTextField(){
        dropDownTextField.inputView = businessPickerView
        dropDownTextField.text = UserDefaults.standard.string(forKey: "pickedBusiness")!
    }
    
    func setUpBusiPickerView(){
        businessPickerView.delegate = self
        businessPickerView.dataSource = self
        businessPickerView.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        businessPickerView.addShadow(withCornerRadius: 0)
    }
    
    func setUpMapView(with list: [AnyObject]){
        // also add a condition for when the list is a kind of [YLPBusiness]
        if list is [USRestStop]{
            mapView.showsCompass = true
            mapView.showsScale = true
            mapView.setRegion(myRegion, animated: true)
            mapView.addAnnotations(list as! [USRestStop])
            mapView.showsUserLocation = true
        }
    }
    
    // MARK: - Gesture recognizer code
    
    func addPanGestureTo(thisView: UIView){
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        thisView.addGestureRecognizer(panGestureRecognizer)
    }
    
        func didPan(_ sender: UIPanGestureRecognizer) {
        guard let _ = sender.view else {return}
        let yTransaction = sender.translation(in: self.view).y
        let yVelocity = sender.velocity(in: self.view).y
        print("Y velocity is: \(yVelocity)")
        if topViewUpperConstraint.hasExceeded(verticalUpperLimit: verticalUpperLimit){
            totalYTransaction += yTransaction
            topViewUpperConstraint.constant = logConstraintValueForYPosition(totalYTransaction, verticalUpperLimit)
            if sender.state == .ended {
                
                
                animateBackToUpperLimit(yVelocity: yVelocity)
                
            }
        } else {
            topViewUpperConstraint.constant += yTransaction
            
            if sender.state == .ended {
                if (topViewUpperConstraint.constant > -500 && topViewUpperConstraint.constant < -300  && yVelocity > 0){
                    animateBackToMiddleLimit(yVelocity: yVelocity)
                } else if (topViewUpperConstraint.constant > -500 && topViewUpperConstraint.constant < -300 && yVelocity < 0){
                    animateBackToUpperLimit(yVelocity: yVelocity)
                } else if ((topViewUpperConstraint.constant > -300 && topViewUpperConstraint.constant < -55 && yVelocity > 0)){
                    animateBackToLowerLimit(yVelocity: yVelocity)
                } else if ((topViewUpperConstraint.constant > -300 && topViewUpperConstraint.constant < -55 && yVelocity < 0)){
                    animateBackToMiddleLimit(yVelocity: yVelocity)
                } else if topViewUpperConstraint.constant > -55 {
                    animateBackToLowerLimit(yVelocity: yVelocity)
                }
            }
        }
        
        
        sender.setTranslation(CGPoint.zero, in: self.view)
        
    }
    
    func animateBackToUpperLimit(yVelocity: CGFloat){
        self.topViewUpperConstraint.constant = verticalUpperLimit
        self.childController.tableView.isScrollEnabled = true
        addDimView()
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: springDamping(yVelocity: yVelocity), initialSpringVelocity: 10, options: .allowUserInteraction, animations: {
            self.view.layoutIfNeeded()
            self.totalYTransaction = self.verticalUpperLimit
        }, completion: nil)
    }
    
    func animateBackToMiddleLimit(yVelocity: CGFloat){
        self.topViewUpperConstraint.constant = verticalMiddleLimit
        self.childController.tableView.isScrollEnabled = false
        self.removeDimView()
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: .allowUserInteraction, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func animateBackToLowerLimit(yVelocity: CGFloat){
        self.topViewUpperConstraint.constant = verticalLowerLimit
        self.childController.tableView.isScrollEnabled = false
        self.removeDimView()
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: springDamping(yVelocity: yVelocity), initialSpringVelocity: 10, options: .allowUserInteraction, animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    
    
    func logConstraintValueForYPosition(_ yPosition: CGFloat, _ verticalLimit: CGFloat) -> CGFloat{
        return verticalLimit * (1 + log10(yPosition / verticalLimit))
    }
    
    func springDamping(yVelocity: CGFloat) -> CGFloat{
        //print("Damping is: \(max(0.5, abs(log10(abs(yVelocity / 15000)))))")
        //return max(0.5, abs(log10(abs(yVelocity / 15000))))
        let velocity = abs(yVelocity)
        if velocity <= 1000 && velocity >= 0{
            return 1.0
        } else if velocity <= 2000 && velocity > 1000{
            return 0.9
        } else if velocity <= 3000 && velocity > 2000{
            return 0.8
        } else if velocity <= 4000 && velocity > 3000{
            return 0.7
        } else if velocity <= 5000 && velocity > 4000{
            return 0.6
        } else if velocity <= 6000 && velocity > 5000{
            return 0.5
        } else if velocity <= 7000 && velocity > 6000{
            return 0.5
        } else if velocity <= 8000 && velocity > 7000{
            return 0.5
        } else if velocity <= 9000 && velocity > 8000{
            return 0.5
        } else if velocity >= 10000{
            return 0.6
        } else {return 0.5}
    }
    
}

extension NSLayoutConstraint{
    func hasExceeded(verticalUpperLimit:  CGFloat) -> Bool{
        
        return self.constant < verticalUpperLimit
        
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


extension NearByViewController: BusinessSearchResultTableViewControllerDelegate{
    
    func businessSearchResultTableViewStartedGettingBusiness() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
    }
    
    func businessSearchResultTableViewStopedGettingBusiness(with searchResultList: [AnyObject]){
        setUpMapView(with: searchResultList)
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        animateBackToMiddleLimit(yVelocity: 500)
    }
    
}

extension NearByViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateBackToLowerLimit(yVelocity: 500)
    }
}

