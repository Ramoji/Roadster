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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.isHidden = true
        getUserCurrentLocation()
        setUpSegmentedControl()
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        getUserCurrentLocation()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    func setUpSegmentedControl(){
        segmentedControl.addTarget(self, action: #selector(switchMapSatellite), for: .valueChanged)
        segmentedControl.layer.backgroundColor = UIColor.white.cgColor
        
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
                    userCurrentLocation = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                    getMinMaxLatLong()
                    performFetch()
                    setUpMapView()
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






