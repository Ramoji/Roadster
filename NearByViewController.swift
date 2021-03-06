
//  Copyright © 2016 A Ja. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import Dispatch
import CoreData
import YelpAPI


struct ChildControllersUpperConstraints {
    static let businessSearchResultControllerTopConstraintIdentifier = "businessSearchResultControllerTopConstraintIdentifier"
    static let businessDetailViewControllerTopConstraintIdentifier = "businessDetailControllerTopConstraintIdentifier"
    static let nearStaticRestStopDetailViewControllerTopConstraint = "nearStaticRestStopDetailViewController"
    static let addressViewControllerTopConstraint = "addressViewControllerTopConstraint"
}

struct NearByViewControllerNotificationIDs{
    static let businessDetailViewControllerNeedsUpdate = "businessDetailViewControllerNeedsUpdate"
    static let nearStaticRestStopDetailViewControllerNeedsUpdate = "nearStaticRestStopDetailViewControllerNeedsUpdate"
    static let addressViewControllerNeedsUpdate = "addressViewControllerNeedsUpdate"
}

class NearByViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!

    var managedObjectContext: NSManagedObjectContext!
 
    let concurrentQueue = DispatchQueue(label: "myQueue", attributes: .concurrent)
    
    var businessSearchResultTableController: BusinessSearchResultTableViewController!
    var businessDetailViewController: BusinessDetailViewController!
    var nearStaticRestStopDetailViewController: NearStaticRestStopDetailViewController!
    var addressViewController: AddressViewController!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    var verticalUpperLimit: CGFloat = -500
    var totalExceedingUpperLimit: CGFloat = -500 //Exceeding limit y transation (change name)
    var verticalLowerLimit: CGFloat = -55
    var verticalHidingLimit: CGFloat = 100
    var verticalMiddleLimit: CGFloat = -250
    var shouldAddSearchTableView = true
    var locationManager: CLLocationManager = CLLocationManager()
    var currentUserLocation: CLLocation!

    override func viewDidLoad() {
        super.viewDidLoad()
        initiateTransactionForScreenMovementLimits()
        mapView.showsUserLocation  = true
        setUpSegmentedControl()
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        super.viewDidAppear(animated)
        if let nearStaticRestStopDetailViewController = nearStaticRestStopDetailViewController{
        nearStaticRestStopDetailViewController.nearRestStopChildDetailTableViewController.setUpViewForRestStop()
        }
        
    }

    override func loadView() {
        
        super.loadView()
        
    }

    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
        print("*** Receiving Memory Warning from NearByViewController!")
        
    }
    
    func initiateTransactionForScreenMovementLimits(){
        verticalUpperLimit = self.view.bounds.height * 0.75 * -1
        totalExceedingUpperLimit = self.view.bounds.height * 0.75 * -1
        verticalLowerLimit  = -55
        verticalHidingLimit = 100
        verticalMiddleLimit = self.view.bounds.height * 0.37 * -1
    }

    func switchMapSatellite(){
        
        if segmentedControl.selectedSegmentIndex == 0 {
          mapView.mapType = .standard
        } else if segmentedControl.selectedSegmentIndex == 1 {
            mapView.mapType = .hybrid
        }
        
    }
    
    
    func showLocationServicesDeniedAlert(){
        
        let alert = UIAlertController(title: "Location Services Disabled", message: "Location Services is disabled. Please enable location servises in order for this app to function properly.", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)
        
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
            
        }){ (Bool) -> Void in
            dimView.removeFromSuperview()
        }
    }
    
    // MARK: - Set Ups
    
    func setUpSegmentedControl(){
        segmentedControl.addTarget(self, action: #selector(switchMapSatellite), for: .valueChanged)
        segmentedControl.layer.backgroundColor = UIColor.white.cgColor
        
    }

    func setUpMapView(with list: [AnyObject], and currentLocation: CLLocationCoordinate2D){
        
        guard list.count != 0 else {
            let mapRegionRectTuple = getMapRegion(with: list, and: currentLocation)
            mapView.showsCompass = true
            mapView.showsScale = true
            mapView.setRegion(mapRegionRectTuple.mapRegion, animated: true)
            mapView.showsUserLocation = true
            mapView.setVisibleMapRect(mapRegionRectTuple.mapRect, edgePadding: UIEdgeInsets(top: 30.0, left: 0.0, bottom: 280.0, right: 0.0), animated: true)
            mapView.removeAnnotations(mapView.annotations)
            return
        }
        
        let mapRegionRectTuple = getMapRegion(with: list, and: currentLocation)
        mapView.removeAnnotations(mapView.annotations)
    
        if list is [USRestStop]{
            mapView.showsCompass = true
            mapView.showsScale = true
            mapView.setRegion(mapRegionRectTuple.mapRegion, animated: true)
            mapView.addAnnotations(list as! [USRestStop])
            mapView.showsUserLocation = true
            
        } else if list is [YLPBusiness]{
            let businessList = list as! [YLPBusiness]
            mapView.showsCompass = true
            mapView.showsScale = true
            mapView.setRegion(mapRegionRectTuple.mapRegion, animated: true)
            var yelpBusinessAnnotations: [YelpBusinessAnnotation] = [] // Created YelpBusinessAnnotation to bridge YLPBusiness, because YLPBusiness does not conform to MKAnnotation.
            for business in businessList{
                if business.location.coordinate != nil {
                    let businessAnnotation = YelpBusinessAnnotation(coordinate: CLLocationCoordinate2D(latitude: (business.location.coordinate?.latitude)!, longitude: (business.location.coordinate?.longitude)!), title: business.name, businessID: business.identifier)
                    yelpBusinessAnnotations.append(businessAnnotation)
                }
            }
            mapView.addAnnotations(yelpBusinessAnnotations)
            mapView.showsUserLocation = true
            
        } else if list is [MKMapItem] {
            mapView.showsCompass = true
            mapView.showsScale = true
            mapView.setRegion(mapRegionRectTuple.mapRegion, animated: true)
            let mkMapItems = list as! [MKMapItem]
            var annotations: [MKPlacemark] = []
            for mapItem in mkMapItems{
                annotations.append(mapItem.placemark)
            }
            mapView.addAnnotations(annotations)
            mapView.showsUserLocation = true
        } else if list is [FavoriteLocation]{
            mapView.showsCompass = true
            mapView.showsScale = true
            mapView.setRegion(mapRegionRectTuple.mapRegion, animated: true)
            let favoriteLocations = list as! [FavoriteLocation]
            var annotations: [FavoriteLocation] = []
            for favoriteLocation in favoriteLocations{
                annotations.append(favoriteLocation)
            }
            mapView.addAnnotations(annotations)
            mapView.showsUserLocation = true
        }
                
    }
    
    
    func getMapRegion(with pointsOfInterestList: [AnyObject], and currentLocation: CLLocationCoordinate2D) -> (mapRegion: MKCoordinateRegion, mapRect: MKMapRect){
        
        guard pointsOfInterestList.count != 0 else {
            let mapRegion = MKCoordinateRegionMakeWithDistance(currentLocation, 80467, 80467)
            let lowerLeftCoordinate = CLLocationCoordinate2DMake(currentLocation.latitude - mapRegion.span.latitudeDelta * 0.5, currentLocation.longitude - mapRegion.span.longitudeDelta * 0.5)
            let upperRightCoordinate = CLLocationCoordinate2DMake(currentLocation.latitude + mapRegion.span.latitudeDelta * 0.5, currentLocation.longitude + mapRegion.span.longitudeDelta * 0.5)
            let lowerLeftMapPoint = MKMapPointForCoordinate(lowerLeftCoordinate)
            let upperRightMapPoint = MKMapPointForCoordinate(upperRightCoordinate)
            
            let mapRect = MKMapRectMake(min(lowerLeftMapPoint.x , upperRightMapPoint.x), min(lowerLeftMapPoint.y, upperRightMapPoint.y), abs(upperRightMapPoint.x - lowerLeftMapPoint.x), abs(upperRightMapPoint.y - lowerLeftMapPoint.y))
            return (mapRegion, mapRect)
        }
        
        if pointsOfInterestList is [USRestStop]{  // CASE ONE
        
            let list = pointsOfInterestList as! [USRestStop]
            var unsortedLatitudes: [Double] = []
            var unsortedLongitudes: [Double] = []
            
            guard list.count > 1  else {
                let restStopCLLocations = CLLocation(latitude: list.first!.latitude, longitude: list.first!.longitude)
                
                let distanceFromUser = currentUserLocation.distance(from: restStopCLLocations)
                let userCLLocationCoordinate2D = CLLocationCoordinate2D(latitude: currentUserLocation.coordinate.latitude, longitude: currentUserLocation.coordinate.longitude)
                let region = MKCoordinateRegionMakeWithDistance(userCLLocationCoordinate2D, distanceFromUser + 100000, distanceFromUser + 10000)
            
                let upperLeftCoordinate = CLLocation(latitude: region.span.latitudeDelta + (region.span.latitudeDelta * 0.5), longitude: region.span.longitudeDelta - (region.span.longitudeDelta * 0.5))
                let lowerRightCoordinate = CLLocation(latitude: region.span.latitudeDelta - (region.span.latitudeDelta * 0.5), longitude: region.span.longitudeDelta + (region.span.longitudeDelta * 0.5))
                
                let upperRightMapPoint = MKMapPointForCoordinate(upperLeftCoordinate.coordinate)
                let lowerLeftMapPoint = MKMapPointForCoordinate(lowerRightCoordinate.coordinate)
                
                let mapRect = MKMapRectMake(min(lowerLeftMapPoint.x, upperRightMapPoint.x), min(lowerLeftMapPoint.y, upperRightMapPoint.y), abs(upperRightMapPoint.x - lowerLeftMapPoint.x), abs(upperRightMapPoint.y - lowerLeftMapPoint.y))
                
                return (mapRegion: region, mapRect: mapRect)
            
            }
            
            for restStop in list{
                unsortedLatitudes.append(restStop.latitude)
                unsortedLongitudes.append(restStop.longitude)
            }
            

            let sortedLatitude = unsortedLatitudes.sorted{lhs, rhs in
                return lhs < rhs
            }
            let sortedLongitude = unsortedLongitudes.sorted{ lhs, rhs in
                return lhs < rhs
            }
            
            let lowerLeftCoordinate = CLLocation(latitude: sortedLatitude.first!, longitude: sortedLongitude.first!)
            let upperRightCoordinate = CLLocation(latitude: sortedLatitude.last!, longitude: sortedLongitude.last!)

            let lowerLeftMapPoint = MKMapPointForCoordinate(lowerLeftCoordinate.coordinate)
            let upperRightMapPoint = MKMapPointForCoordinate(upperRightCoordinate.coordinate)
            
            let mapRect = MKMapRectMake(min(lowerLeftMapPoint.x, upperRightMapPoint.x), min(lowerLeftMapPoint.y, upperRightMapPoint.y), abs(upperRightMapPoint.x - lowerLeftMapPoint.x), abs(upperRightMapPoint.y - lowerLeftMapPoint.y))
            let region = MKCoordinateRegionForMapRect(mapRect)
            return (mapRegion: region, mapRect: mapRect)
            
        } else if pointsOfInterestList is [YLPBusiness]{  //CASE TWO
            
            let list = pointsOfInterestList as! [YLPBusiness]
            
            var unsortedLatitude: [Double] = []
            var unsortedLongitude: [Double] = []
            
            let userCLLocationCoordinate2D = CLLocationCoordinate2D(latitude: currentUserLocation.coordinate.latitude, longitude: currentUserLocation.coordinate.longitude)
            
            guard list.count > 1  else {
                
                guard let businessCoordinates = list.first!.location.coordinate else {
                    
                    
                    let region = MKCoordinateRegionMakeWithDistance(userCLLocationCoordinate2D, 10000, 10000)
                    
                    let upperLeftCoordinate = CLLocation(latitude: region.span.latitudeDelta + (region.span.latitudeDelta * 0.5), longitude: region.span.longitudeDelta - (region.span.longitudeDelta * 0.5))
                    let lowerRightCoordinate = CLLocation(latitude: region.span.latitudeDelta - (region.span.latitudeDelta * 0.5), longitude: region.span.longitudeDelta + (region.span.longitudeDelta * 0.5))
                    
                    let upperRightMapPoint = MKMapPointForCoordinate(upperLeftCoordinate.coordinate)
                    let lowerLeftMapPoint = MKMapPointForCoordinate(lowerRightCoordinate.coordinate)
                    
                    let mapRect = MKMapRectMake(min(lowerLeftMapPoint.x, upperRightMapPoint.x), min(lowerLeftMapPoint.y, upperRightMapPoint.y), abs(upperRightMapPoint.x - lowerLeftMapPoint.x), abs(upperRightMapPoint.y - lowerLeftMapPoint.y))
                    
                    return (mapRegion: region, mapRect: mapRect)
                }
                
                let businessCLLocation = CLLocation(latitude: businessCoordinates.latitude, longitude: businessCoordinates.longitude)
                
                let distanceFromUser = currentUserLocation.distance(from: businessCLLocation)
            
                let region = MKCoordinateRegionMakeWithDistance(userCLLocationCoordinate2D, distanceFromUser + 100000, distanceFromUser + 10000)
                
                let upperLeftCoordinate = CLLocation(latitude: region.span.latitudeDelta + (region.span.latitudeDelta * 0.5), longitude: region.span.longitudeDelta - (region.span.longitudeDelta * 0.5))
                let lowerRightCoordinate = CLLocation(latitude: region.span.latitudeDelta - (region.span.latitudeDelta * 0.5), longitude: region.span.longitudeDelta + (region.span.longitudeDelta * 0.5))
                
                let upperRightMapPoint = MKMapPointForCoordinate(upperLeftCoordinate.coordinate)
                let lowerLeftMapPoint = MKMapPointForCoordinate(lowerRightCoordinate.coordinate)
                
                let mapRect = MKMapRectMake(min(lowerLeftMapPoint.x, upperRightMapPoint.x), min(lowerLeftMapPoint.y, upperRightMapPoint.y), abs(upperRightMapPoint.x - lowerLeftMapPoint.x), abs(upperRightMapPoint.y - lowerLeftMapPoint.y))
                
                return (mapRegion: region, mapRect: mapRect)
                
            }
            
            for business in list {
                if business.location.coordinate != nil {
                    unsortedLatitude.append((business.location.coordinate?.latitude)!)
                    unsortedLongitude.append((business.location.coordinate?.longitude)!)
                }
            }
            
            let sortedLatitude = unsortedLatitude.sorted{ lhs, rhs in
                return lhs < rhs
            }
            
            let sortedLongitude = unsortedLongitude.sorted{ lhs, rhs in
                return lhs < rhs
            }
            
            let lowerLeftCoordinate = CLLocation(latitude: sortedLatitude.first!, longitude: sortedLongitude.first!)
            let upperRightCoordinate = CLLocation(latitude: sortedLatitude.last!, longitude: sortedLongitude.last!)
            
            let lowerLeftMapPoint = MKMapPointForCoordinate(lowerLeftCoordinate.coordinate)
            let upperRightMapPoint = MKMapPointForCoordinate(upperRightCoordinate.coordinate)
            
            let mapRect = MKMapRectMake(min(lowerLeftMapPoint.x, upperRightMapPoint.x), min(lowerLeftMapPoint.y, upperRightMapPoint.y), abs(upperRightMapPoint.x - lowerLeftMapPoint.x), abs(upperRightMapPoint.y - lowerLeftMapPoint.y))
            
            let region = MKCoordinateRegionForMapRect(mapRect)
            
            return (mapRegion: region, mapRect: mapRect)
            
        } else if pointsOfInterestList is [MKMapItem]{ //CASE THREE
            
            
            let list = pointsOfInterestList as! [MKMapItem]
            var unsortedLatitude: [Double] = []
            var unsortedLongitude: [Double] = []
            
            
            guard list.count > 1  else {
                
                let mapItem = list.first!
                let addressCLLocations = CLLocation(latitude: mapItem.placemark.coordinate.latitude, longitude: mapItem.placemark.coordinate.longitude)
                
                let distanceFromUser = currentUserLocation.distance(from: addressCLLocations)
                let userCLLocationCoordinate2D = CLLocationCoordinate2D(latitude: currentUserLocation.coordinate.latitude, longitude: currentUserLocation.coordinate.longitude)
                let region = MKCoordinateRegionMakeWithDistance(userCLLocationCoordinate2D, distanceFromUser + 100000, distanceFromUser + 10000)
                
                let upperLeftCoordinate = CLLocation(latitude: region.span.latitudeDelta + (region.span.latitudeDelta * 0.5), longitude: region.span.longitudeDelta - (region.span.longitudeDelta * 0.5))
                let lowerRightCoordinate = CLLocation(latitude: region.span.latitudeDelta - (region.span.latitudeDelta * 0.5), longitude: region.span.longitudeDelta + (region.span.longitudeDelta * 0.5))
                
                let upperRightMapPoint = MKMapPointForCoordinate(upperLeftCoordinate.coordinate)
                let lowerLeftMapPoint = MKMapPointForCoordinate(lowerRightCoordinate.coordinate)
                
                let mapRect = MKMapRectMake(min(lowerLeftMapPoint.x, upperRightMapPoint.x), min(lowerLeftMapPoint.y, upperRightMapPoint.y), abs(upperRightMapPoint.x - lowerLeftMapPoint.x), abs(upperRightMapPoint.y - lowerLeftMapPoint.y))
                
                return (mapRegion: region, mapRect: mapRect)
                
            }
            
            
            for mkMapItem in list {
                unsortedLatitude.append(mkMapItem.placemark.coordinate.latitude)
                unsortedLongitude.append(mkMapItem.placemark.coordinate.longitude)
            }
            
            let sortedLatitude = unsortedLatitude.sorted{ lhs, rhs in
                return lhs < rhs
            }
            
            let sortedLongitude = unsortedLongitude.sorted{ lhs, rhs in
                return lhs < rhs
            }
            
            let lowerLeftCoordinate = CLLocation(latitude: sortedLatitude.first!, longitude: sortedLongitude.first!)
            let upperRightCoordinate = CLLocation(latitude: sortedLatitude.last!, longitude: sortedLongitude.last!)
            
            let lowerLeftMapPoint = MKMapPointForCoordinate(lowerLeftCoordinate.coordinate)
            let upperRightMapPoint = MKMapPointForCoordinate(upperRightCoordinate.coordinate)
            
            let mapRect = MKMapRectMake(min(lowerLeftMapPoint.x, upperRightMapPoint.x), min(lowerLeftMapPoint.y, upperRightMapPoint.y), abs(upperRightMapPoint.x - lowerLeftMapPoint.x), abs(upperRightMapPoint.y - lowerLeftMapPoint.y))
            
            let region = MKCoordinateRegionForMapRect(mapRect)
            
            return (mapRegion: region, mapRect: mapRect)
            
        } else { //CASE FOUR list is [FavoriteLocation]
            let list = pointsOfInterestList as! [FavoriteLocation]
            // We dont need to check if the list only has one element because the user only taps on one FavoriteLocation at a time.
            let favoriteLocation = list.first!
            let region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: favoriteLocation.placemark.coordinate.latitude, longitude: favoriteLocation.coordinate.longitude), 5000, 5000)
            let a = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
                region.center.latitude + region.span.latitudeDelta / 2,
                region.center.longitude - region.span.longitudeDelta / 2))
            let b = MKMapPointForCoordinate(CLLocationCoordinate2DMake(
                region.center.latitude - region.span.latitudeDelta / 2,
                region.center.longitude + region.span.longitudeDelta / 2))
            let mapRect = MKMapRectMake(min(a.x,b.x),min(a.y,b.y), abs(a.x-b.x), abs(a.y-b.y))
            return (mapRegion: region, mapRect: mapRect)
        }
    }
    
    // MARK: - Gesture recognizer code
    
    func businessSearchResultTableControllerdidPan(_ sender: UIPanGestureRecognizer) {
        
        guard let businessSearchResultControllerTopConstraint = self.view.findConstraint(for: ChildControllersUpperConstraints.businessSearchResultControllerTopConstraintIdentifier) else {return}
        guard let _ = sender.view else {return}
        businessSearchResultTableController.searchBar.resignFirstResponder()
        businessSearchResultTableController.searchBar.setShowsCancelButton(false, animated: true)
        businessSearchResultTableController.searchBar.text = ""
        let yTransaction = sender.translation(in: self.view).y
        let yVelocity = sender.velocity(in: self.view).y
        
        if businessSearchResultControllerTopConstraint.hasExceeded(verticalUpperLimit: verticalUpperLimit){
            
            totalExceedingUpperLimit += yTransaction
            
            businessSearchResultControllerTopConstraint.constant = logConstraintValueForYPosition(totalExceedingUpperLimit, verticalUpperLimit)
            if sender.state == .ended {
                
                animateToUpperLimit(yVelocity: yVelocity, and: ChildControllersUpperConstraints.businessSearchResultControllerTopConstraintIdentifier)
            }
            
        } else {
            
            businessSearchResultControllerTopConstraint.constant += yTransaction
            
            if sender.state == .ended {
                if (businessSearchResultControllerTopConstraint.constant > verticalUpperLimit && businessSearchResultControllerTopConstraint.constant < verticalMiddleLimit  && yVelocity > 0){
                    
                    animateToMiddleLimit(yVelocity: yVelocity, and: ChildControllersUpperConstraints.businessSearchResultControllerTopConstraintIdentifier)
                    
                } else if (businessSearchResultControllerTopConstraint.constant > verticalUpperLimit && businessSearchResultControllerTopConstraint.constant < verticalMiddleLimit && yVelocity < 0){
                    
                    animateToUpperLimit(yVelocity: yVelocity, and: ChildControllersUpperConstraints.businessSearchResultControllerTopConstraintIdentifier)
                    
                } else if (businessSearchResultControllerTopConstraint.constant > verticalMiddleLimit && businessSearchResultControllerTopConstraint.constant < -55 && yVelocity > 0){
                    
                    animateToLowerLimit(yVelocity: yVelocity, and: ChildControllersUpperConstraints.businessSearchResultControllerTopConstraintIdentifier)
                    
                } else if (businessSearchResultControllerTopConstraint.constant > verticalMiddleLimit && businessSearchResultControllerTopConstraint.constant < -55 && yVelocity < 0){
                    
                    animateToMiddleLimit(yVelocity: yVelocity, and: ChildControllersUpperConstraints.businessSearchResultControllerTopConstraintIdentifier)
                    
                } else if businessSearchResultControllerTopConstraint.constant > -55 {
                    animateToLowerLimit(yVelocity: yVelocity, and: ChildControllersUpperConstraints.businessSearchResultControllerTopConstraintIdentifier)
                }
            }
        }
        
        
        sender.setTranslation(CGPoint.zero, in: self.view)
        
        
    }
    
    func businessDetailViewControllerDidPan(_ sender: UIPanGestureRecognizer){
        
        guard let businessDetailViewControllerTopConstraint = self.view.findConstraint(for: ChildControllersUpperConstraints.businessDetailViewControllerTopConstraintIdentifier) else {return}
        guard let _ = sender.view else {return}
        
        let yTransaction = sender.translation(in: self.view).y
        let yVelocity = sender.velocity(in: self.view).y
        
        if businessDetailViewControllerTopConstraint.hasExceeded(verticalUpperLimit: verticalUpperLimit){
            totalExceedingUpperLimit += yTransaction
            businessDetailViewControllerTopConstraint.constant = logConstraintValueForYPosition(totalExceedingUpperLimit, verticalUpperLimit)
            if sender.state == .ended {
                
                
                animateToUpperLimit(yVelocity: yVelocity, and: ChildControllersUpperConstraints.businessDetailViewControllerTopConstraintIdentifier)
            }
            
        } else {
            
            businessDetailViewControllerTopConstraint.constant += yTransaction
            
            if sender.state == .ended {
                if (businessDetailViewControllerTopConstraint.constant > verticalUpperLimit && businessDetailViewControllerTopConstraint.constant < verticalMiddleLimit  && yVelocity > 0){
                    
                    animateToMiddleLimit(yVelocity: yVelocity, and: ChildControllersUpperConstraints.businessDetailViewControllerTopConstraintIdentifier)
                    
                } else if (businessDetailViewControllerTopConstraint.constant > verticalUpperLimit && businessDetailViewControllerTopConstraint.constant < verticalMiddleLimit && yVelocity < 0){
                    
                    animateToUpperLimit(yVelocity: yVelocity, and: ChildControllersUpperConstraints.businessDetailViewControllerTopConstraintIdentifier)
                    
                } else if ((businessDetailViewControllerTopConstraint.constant > verticalMiddleLimit && businessDetailViewControllerTopConstraint.constant < -55 && yVelocity > 0)){
                    
                    animateToLowerLimit(yVelocity: yVelocity, and: ChildControllersUpperConstraints.businessDetailViewControllerTopConstraintIdentifier)
                    
                } else if ((businessDetailViewControllerTopConstraint.constant > verticalMiddleLimit && businessDetailViewControllerTopConstraint.constant < -55 && yVelocity < 0)){
                    
                    animateToMiddleLimit(yVelocity: yVelocity, and: ChildControllersUpperConstraints.businessDetailViewControllerTopConstraintIdentifier)
                    
                } else if businessDetailViewControllerTopConstraint.constant > -55 {
                    animateToLowerLimit(yVelocity: yVelocity, and: ChildControllersUpperConstraints.businessDetailViewControllerTopConstraintIdentifier)
                }
            }
        }
        
        
        sender.setTranslation(CGPoint.zero, in: self.view)
        
    }

    func animateToUpperLimit(yVelocity: CGFloat, and topConstraintIdentifier: String){
        
        guard let topConstraint = self.view.findConstraint(for: topConstraintIdentifier) else {return}
        
        switch topConstraintIdentifier{
            
        case ChildControllersUpperConstraints.businessSearchResultControllerTopConstraintIdentifier:
            
            topConstraint.constant = verticalUpperLimit
            self.businessSearchResultTableController.tableView.isScrollEnabled = true
            addDimView()
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: springDamping(yVelocity: yVelocity), initialSpringVelocity: 10, options: .allowUserInteraction, animations: {
                self.view.layoutIfNeeded()
                self.totalExceedingUpperLimit = self.verticalUpperLimit
            }, completion: nil)
            
            break
            
        case ChildControllersUpperConstraints.businessDetailViewControllerTopConstraintIdentifier:
            
            topConstraint.constant = verticalUpperLimit
            self.businessDetailViewController.businessDetailChildTableViewController.tableView.isScrollEnabled = true
            addDimView()
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: springDamping(yVelocity: yVelocity), initialSpringVelocity: 10, options: .allowUserInteraction, animations: {
                self.view.layoutIfNeeded()
                self.totalExceedingUpperLimit = self.verticalUpperLimit
            }, completion: nil)
            
            break
            
        case ChildControllersUpperConstraints.nearStaticRestStopDetailViewControllerTopConstraint:
            topConstraint.constant = verticalUpperLimit
            if let table = nearStaticRestStopDetailViewController.nearRestStopChildDetailTableViewController.tableView {
                table.isScrollEnabled = true
            }
            addDimView()
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: springDamping(yVelocity: yVelocity), initialSpringVelocity: 10, options: .allowUserInteraction, animations: {
                self.view.layoutIfNeeded()
                self.totalExceedingUpperLimit = self.verticalUpperLimit
            }, completion: nil)
            
            break
            
        case ChildControllersUpperConstraints.addressViewControllerTopConstraint:
            topConstraint.constant = verticalUpperLimit
            if let table = addressViewController.addressTableViewController.tableView{
                table.isScrollEnabled = true
            }
            
            addDimView()
            
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: springDamping(yVelocity: yVelocity), initialSpringVelocity: 10, options: .allowUserInteraction, animations: {
                self.view.layoutIfNeeded()
                self.totalExceedingUpperLimit = self.verticalUpperLimit
            }, completion: nil)
            
            break
            
        default:
            print("In default!")
            
        }
    }
    
    func animateToMiddleLimit(yVelocity: CGFloat, and topConstraintIdentifier: String){
        
        guard let topConstraint = self.view.findConstraint(for: topConstraintIdentifier) else {return}
        
        switch topConstraintIdentifier{
        case ChildControllersUpperConstraints.businessSearchResultControllerTopConstraintIdentifier:
            
            topConstraint.constant = verticalMiddleLimit
            self.businessSearchResultTableController.tableView.isScrollEnabled = false
            self.removeDimView()
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: .allowUserInteraction, animations: {
                self.view.layoutIfNeeded()
            }, completion: { completed in
                self.businessSearchResultTableController.searchBar.resignFirstResponder()
            })
            break
            
        case ChildControllersUpperConstraints.businessDetailViewControllerTopConstraintIdentifier:
            
            topConstraint.constant = verticalMiddleLimit
            self.businessDetailViewController.businessDetailChildTableViewController.tableView.isScrollEnabled = false
            self.removeDimView()
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: .allowUserInteraction, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
            
            break
            
        case ChildControllersUpperConstraints.nearStaticRestStopDetailViewControllerTopConstraint:
            topConstraint.constant = verticalMiddleLimit
            if let table = nearStaticRestStopDetailViewController.nearRestStopChildDetailTableViewController.tableView {
                table.isScrollEnabled = false
            }
            self.removeDimView()
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: .allowUserInteraction, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
            break
            
        case ChildControllersUpperConstraints.addressViewControllerTopConstraint:
            topConstraint.constant = verticalMiddleLimit
            if let table = addressViewController.addressTableViewController.tableView{
                table.isScrollEnabled = false
            }
            self.removeDimView()
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 10, options: .allowUserInteraction, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
            break
            
        default:
            print("In Default!")
        }
        
    }
    
    func animateToLowerLimit(yVelocity: CGFloat, and topConstraintIdentifier: String){
        
        guard let topConstraint = self.view.findConstraint(for: topConstraintIdentifier) else {return}
        
        switch topConstraintIdentifier{
        case ChildControllersUpperConstraints.businessSearchResultControllerTopConstraintIdentifier:
            
            topConstraint.constant = verticalLowerLimit
            self.businessSearchResultTableController.tableView.isScrollEnabled = false
            self.removeDimView()
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: springDamping(yVelocity: yVelocity), initialSpringVelocity: 10, options: .allowUserInteraction, animations: {
                self.view.layoutIfNeeded()
            }, completion: { completed in
                self.businessSearchResultTableController.searchBar.resignFirstResponder()
            })
            break
            
        case ChildControllersUpperConstraints.businessDetailViewControllerTopConstraintIdentifier:
            
            topConstraint.constant = verticalLowerLimit
            self.businessDetailViewController.businessDetailChildTableViewController.tableView.isScrollEnabled = false
            self.removeDimView()
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: springDamping(yVelocity: yVelocity), initialSpringVelocity: 10, options: .allowUserInteraction, animations: {
                self.view.layoutIfNeeded()
            }, completion: { completed in
                self.businessSearchResultTableController.searchBar.resignFirstResponder()
            })
            break
            
        case ChildControllersUpperConstraints.nearStaticRestStopDetailViewControllerTopConstraint:
            
            topConstraint.constant = verticalLowerLimit
            if let table = nearStaticRestStopDetailViewController.nearRestStopChildDetailTableViewController.tableView {
                table.isScrollEnabled = false
            }
            self.removeDimView()
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: springDamping(yVelocity: yVelocity), initialSpringVelocity: 10, options: .allowUserInteraction, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
            break
            
        case ChildControllersUpperConstraints.addressViewControllerTopConstraint:
            topConstraint.constant = verticalLowerLimit
            if let table = addressViewController.addressTableViewController.tableView{
                table.isScrollEnabled = false
            }
            removeDimView()
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: springDamping(yVelocity: yVelocity), initialSpringVelocity: 10, options: .allowUserInteraction, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
            
            break
            
        default:
            print("In Default!")
        }
        
    }
    
    func animateToHidingLimit(yVelocity: CGFloat, and topConstraintIdentifier: String, completionHandler: @escaping (Bool) -> ()){
        guard let topConstraint = self.view.findConstraint(for: topConstraintIdentifier) else {return}
            topConstraint.constant = verticalHidingLimit
            self.businessSearchResultTableController.tableView.isScrollEnabled = false
        UIView.animate(withDuration: 0.3, animations: {self.view.layoutIfNeeded()}){ isComplete in
            completionHandler(isComplete)
        }
    }

    func logConstraintValueForYPosition(_ yPosition: CGFloat, _ verticalLimit: CGFloat) -> CGFloat{
        return verticalLimit * (1 + log10(yPosition / verticalLimit))
    }
    
    func springDamping(yVelocity: CGFloat) -> CGFloat{

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
    
    func addBusinessDetailViewController(withBusinessID businessID: String, and currentLocation: CLLocation){
        
        businessDetailViewController = storyboard?.instantiateViewController(withIdentifier: "BusinessDetailViewController") as! BusinessDetailViewController
        businessDetailViewController.delegates.add(delegate: self)
        businessDetailViewController.businessID = businessID
        businessDetailViewController.currentUserLocation = currentLocation
        view.addSubview(businessDetailViewController.view)
        self.addChildViewController(businessDetailViewController)
        self.addChildViewController(businessDetailViewController)
        businessDetailViewController.didMove(toParentViewController: self)
        
        
        businessDetailViewController.view.translatesAutoresizingMaskIntoConstraints = false
        let heightConstraint = businessDetailViewController.view.heightAnchor.constraint(equalToConstant: abs(verticalUpperLimit))
        let leadingConstraint = businessDetailViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        let widthConstraint = businessDetailViewController.view.widthAnchor.constraint(equalToConstant: self.view.bounds.width)
        let topConstraint = businessDetailViewController.view.topAnchor.constraint(equalTo: self.bottomLayoutGuide.topAnchor, constant: -55)
        
        topConstraint.identifier = ChildControllersUpperConstraints.businessDetailViewControllerTopConstraintIdentifier
        
        let constraints: [NSLayoutConstraint] = [heightConstraint, leadingConstraint, widthConstraint, topConstraint]
        NSLayoutConstraint.activate(constraints)
        
        let gestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(businessDetailViewControllerDidPan(_:)))
        businessDetailViewController.view.addGestureRecognizer(gestureRecognizer)
        
    }
    
    func addChildBusinessSearchTableViewController(){
        
        businessSearchResultTableController = storyboard?.instantiateViewController(withIdentifier: "BusinessSearchResultTableViewController") as! BusinessSearchResultTableViewController
        businessSearchResultTableController.delegate = self
        businessSearchResultTableController.managedObjectContext = managedObjectContext
        
        
        view.addSubview(businessSearchResultTableController.view)
        self.addChildViewController(businessSearchResultTableController)
        businessSearchResultTableController.didMove(toParentViewController: self)
        
        businessSearchResultTableController.view.translatesAutoresizingMaskIntoConstraints = false
        let heightConstraint = businessSearchResultTableController.view.heightAnchor.constraint(equalToConstant: self.view.bounds.height)
        let leadingConstraint = businessSearchResultTableController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        let widthConstraint = businessSearchResultTableController.view.widthAnchor.constraint(equalToConstant: self.view.bounds.width)
        let topViewUpperConstraint = businessSearchResultTableController.view.topAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: -55)
        topViewUpperConstraint.identifier = ChildControllersUpperConstraints.businessSearchResultControllerTopConstraintIdentifier
        
        NSLayoutConstraint.activate([heightConstraint, leadingConstraint, widthConstraint, topViewUpperConstraint])
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(businessSearchResultTableControllerdidPan(_:)))
        businessSearchResultTableController.view.addGestureRecognizer(panGestureRecognizer)
    }
    
    func addNearStaticRestStopDetailViewController(with restStop: USRestStop){
        
        nearStaticRestStopDetailViewController = storyboard?.instantiateViewController(withIdentifier: "nearStaticRestStopDetailViewController")  as! NearStaticRestStopDetailViewController
        nearStaticRestStopDetailViewController.restStop = restStop
        nearStaticRestStopDetailViewController.delegates.add(delegate: self)
        view.addSubview(nearStaticRestStopDetailViewController.view)
        self.addChildViewController(nearStaticRestStopDetailViewController)
        nearStaticRestStopDetailViewController.didMove(toParentViewController: self)
        
        nearStaticRestStopDetailViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        let heightConstraint = nearStaticRestStopDetailViewController.view.heightAnchor.constraint(equalToConstant: abs(verticalUpperLimit))
        let leadingConstraint = nearStaticRestStopDetailViewController.view.leadingAnchor.constraint(equalTo: self.view.leadingAnchor)
        let trailingConstraint = nearStaticRestStopDetailViewController.view.trailingAnchor.constraint(equalTo: self.view.trailingAnchor)
        let topConstraint = nearStaticRestStopDetailViewController.view.topAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: -55)
        topConstraint.identifier = ChildControllersUpperConstraints.nearStaticRestStopDetailViewControllerTopConstraint
        NSLayoutConstraint.activate([heightConstraint, leadingConstraint, trailingConstraint, topConstraint])
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(nearStaticRestStopDetailViewControllerDidPan(_:)))
        
        nearStaticRestStopDetailViewController.view.addGestureRecognizer(panGesture)
        
    }
    
    func nearStaticRestStopDetailViewControllerDidPan(_ sender: UIPanGestureRecognizer){
        
        
        guard let nearStaticRestStopDetailViewControllerTopConstraint = self.view.findConstraint(for: ChildControllersUpperConstraints.nearStaticRestStopDetailViewControllerTopConstraint) else {return}
        guard let _ = sender.view else {return}
        
        let yTransaction = sender.translation(in: self.view).y
        let yVelocity = sender.velocity(in: self.view).y
        if nearStaticRestStopDetailViewControllerTopConstraint.hasExceeded(verticalUpperLimit: verticalUpperLimit){
            totalExceedingUpperLimit += yTransaction
            nearStaticRestStopDetailViewControllerTopConstraint.constant = logConstraintValueForYPosition(totalExceedingUpperLimit, verticalUpperLimit)
            if sender.state == .ended {
                
                
                animateToUpperLimit(yVelocity: yVelocity, and: ChildControllersUpperConstraints.nearStaticRestStopDetailViewControllerTopConstraint)
            }
            
        } else {
            
            nearStaticRestStopDetailViewControllerTopConstraint.constant += yTransaction
            
            if sender.state == .ended {
                if (nearStaticRestStopDetailViewControllerTopConstraint.constant > verticalUpperLimit && nearStaticRestStopDetailViewControllerTopConstraint.constant < verticalMiddleLimit  && yVelocity > 0){
                    
                    animateToMiddleLimit(yVelocity: yVelocity, and: ChildControllersUpperConstraints.nearStaticRestStopDetailViewControllerTopConstraint)
                    
                } else if (nearStaticRestStopDetailViewControllerTopConstraint.constant > verticalUpperLimit && nearStaticRestStopDetailViewControllerTopConstraint.constant < verticalMiddleLimit && yVelocity < 0){
                    
                    animateToUpperLimit(yVelocity: yVelocity, and: ChildControllersUpperConstraints.nearStaticRestStopDetailViewControllerTopConstraint)
                    
                } else if ((nearStaticRestStopDetailViewControllerTopConstraint.constant > verticalMiddleLimit && nearStaticRestStopDetailViewControllerTopConstraint.constant < -55 && yVelocity > 0)){
                    
                    animateToLowerLimit(yVelocity: yVelocity, and: ChildControllersUpperConstraints.nearStaticRestStopDetailViewControllerTopConstraint)
                    
                } else if ((nearStaticRestStopDetailViewControllerTopConstraint.constant > verticalMiddleLimit && nearStaticRestStopDetailViewControllerTopConstraint.constant < -55 && yVelocity < 0)){
                    
                    animateToMiddleLimit(yVelocity: yVelocity, and: ChildControllersUpperConstraints.nearStaticRestStopDetailViewControllerTopConstraint)
                    
                } else if nearStaticRestStopDetailViewControllerTopConstraint.constant > -55 {
                    animateToLowerLimit(yVelocity: yVelocity, and: ChildControllersUpperConstraints.nearStaticRestStopDetailViewControllerTopConstraint)
                }
            }
        }
        
        
        sender.setTranslation(CGPoint.zero, in: self.view)

    }
    
    
    func addAddressViewController(with mapItem: MKMapItem, and currentLocation: CLLocation){
        
        addressViewController = storyboard?.instantiateViewController(withIdentifier: "AddressViewController") as! AddressViewController
        addressViewController.mapItem = mapItem
        addressViewController.currentUserLocation = currentLocation
        addressViewController.delegate = self
        
        view.addSubview(addressViewController.view)
        addChildViewController(addressViewController)
        addressViewController.didMove(toParentViewController: self)
        
        addressViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        let topConstraint = addressViewController.view.topAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor, constant: -55.0)
        topConstraint.identifier = ChildControllersUpperConstraints.addressViewControllerTopConstraint
        
        let leadingConstraint = addressViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let widthConstraint = addressViewController.view.widthAnchor.constraint(equalToConstant: view.bounds.width)
        let heightConstraint = addressViewController.view.heightAnchor.constraint(equalToConstant: abs(verticalUpperLimit))
        NSLayoutConstraint.activate([topConstraint, leadingConstraint, widthConstraint, heightConstraint])
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(addressViewControllerDidPan(_:)))
        
        addressViewController.view.addGestureRecognizer(panGesture)
       
    }
    
    func addressViewControllerDidPan(_ sender: UIPanGestureRecognizer){
        
        guard let _ = sender.view else {return}
        guard let addressViewControllerTopConstraint = self.view.findConstraint(for: ChildControllersUpperConstraints.addressViewControllerTopConstraint) else {return}
        let yVelocity = sender.velocity(in: self.view).y
        
        
        
        let transaction = sender.translation(in: self.view)
        if addressViewControllerTopConstraint.hasExceeded(verticalUpperLimit: verticalUpperLimit){
            
            totalExceedingUpperLimit += transaction.y
            addressViewControllerTopConstraint.constant = logConstraintValueForYPosition(totalExceedingUpperLimit, verticalUpperLimit)
            if sender.state == .ended{
                animateToUpperLimit(yVelocity: 500, and: ChildControllersUpperConstraints.addressViewControllerTopConstraint)
            }
            
        } else {
            
            addressViewControllerTopConstraint.constant += transaction.y
        
            if sender.state == .ended {
                if (addressViewControllerTopConstraint.constant > verticalUpperLimit && addressViewControllerTopConstraint.constant < verticalMiddleLimit  && yVelocity > 0){
                    
                    animateToMiddleLimit(yVelocity: yVelocity, and: ChildControllersUpperConstraints.addressViewControllerTopConstraint)
                    
                } else if (addressViewControllerTopConstraint.constant > verticalUpperLimit && addressViewControllerTopConstraint.constant < verticalMiddleLimit && yVelocity < 0){
                    
                    animateToUpperLimit(yVelocity: yVelocity, and: ChildControllersUpperConstraints.addressViewControllerTopConstraint)
                    
                } else if ((addressViewControllerTopConstraint.constant > verticalMiddleLimit && addressViewControllerTopConstraint.constant < -55 && yVelocity > 0)){
                    
                    animateToLowerLimit(yVelocity: yVelocity, and: ChildControllersUpperConstraints.addressViewControllerTopConstraint)
                    
                } else if ((addressViewControllerTopConstraint.constant > verticalMiddleLimit && addressViewControllerTopConstraint.constant < -55 && yVelocity < 0)){
                    
                    animateToMiddleLimit(yVelocity: yVelocity, and: ChildControllersUpperConstraints.addressViewControllerTopConstraint)
                    
                } else if addressViewControllerTopConstraint.constant > -55 {
                    animateToLowerLimit(yVelocity: yVelocity, and: ChildControllersUpperConstraints.addressViewControllerTopConstraint)
                }
            }
        }
    
        sender.setTranslation(CGPoint.zero, in: self.view)
        
    }
}

extension NearByViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        var annotationView: MKAnnotationView!
        switch annotation{
        case is USRestStop:
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "restStop")
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "restStop")
                annotationView.image = #imageLiteral(resourceName: "restStop").resizeImage(CGSize(width: 20.0, height: 20.0))
            }
            break
            
        case is YelpBusinessAnnotation: // Used YelpBusinessAnnotation to feed in Yelp annotations because YLPBusiness does not conform to MKAnnotation.
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "yelpBusiness")
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "yelpBusiness")
                annotationView.image = #imageLiteral(resourceName: "yelpLocation").resizeImage(CGSize(width: 20.0, height: 20.0))
            }
            break
            
        case is MKMapItem:
            annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "addressPin")
            if annotationView == nil {
                annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "yelpBusiness")
                annotationView.image = #imageLiteral(resourceName: "addressMapItemCellPin").resizeImage(CGSize(width: 20.0, height: 20.0))
            }
            break
            
        default:
            print("*** Incorrect type sent to mapView(:viewFor:) selector")
        }
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView){
        
        var latitude: Double = 0.0
        var longitude: Double = 0.0
        
        if view.annotation is USRestStop {
            let restStop = view.annotation as! USRestStop
            
            latitude = restStop.latitude
            longitude = restStop.longitude
            
            view.image = #imageLiteral(resourceName: "restStop").resizeImage(CGSize(width: 50.0, height: 50.0))
            if let nearStaticRestStopDetailViewController = nearStaticRestStopDetailViewController{
                nearStaticRestStopDetailViewController.restStop = view.annotation as! USRestStop
                NotificationCenter.default.post(name: Notification.Name(rawValue: NearByViewControllerNotificationIDs.nearStaticRestStopDetailViewControllerNeedsUpdate), object: self)
                animateToMiddleLimit(yVelocity: 500, and: ChildControllersUpperConstraints.nearStaticRestStopDetailViewControllerTopConstraint)
            } else {
                addNearStaticRestStopDetailViewController(with: view.annotation as! USRestStop)
                if let _ = businessSearchResultTableController{
                    animateToMiddleLimit(yVelocity: 500, and: ChildControllersUpperConstraints.nearStaticRestStopDetailViewControllerTopConstraint)
                    animateToHidingLimit(yVelocity: 500, and: ChildControllersUpperConstraints.businessSearchResultControllerTopConstraintIdentifier){isCompleted in }
                }
            }
        } else if view.annotation is YelpBusinessAnnotation{
            
            let business = view.annotation as! YelpBusinessAnnotation
            
            latitude = business.coordinate.latitude
            longitude = business.coordinate.longitude
            
            view.image = #imageLiteral(resourceName: "yelpLocation").resizeImage(CGSize(width: 50.0, height: 50.0))
            if let businessDetailViewController = businessDetailViewController{
                let yelpBusinessAnnotation = view.annotation as! YelpBusinessAnnotation
                businessDetailViewController.businessID = yelpBusinessAnnotation.businessID
                NotificationCenter.default.post(name: Notification.Name(rawValue: NearByViewControllerNotificationIDs.businessDetailViewControllerNeedsUpdate), object: self)
                animateToMiddleLimit(yVelocity: 500, and: ChildControllersUpperConstraints.businessDetailViewControllerTopConstraintIdentifier)
            } else {
                let yelpBusinessAnnotation = view.annotation as! YelpBusinessAnnotation
                if let businessID = yelpBusinessAnnotation.businessID{
                    addBusinessDetailViewController(withBusinessID: businessID, and: currentUserLocation)
                    if let _ = businessSearchResultTableController{
                        animateToMiddleLimit(yVelocity: 500, and: ChildControllersUpperConstraints.businessDetailViewControllerTopConstraintIdentifier)
                        animateToHidingLimit(yVelocity: 500, and: ChildControllersUpperConstraints.businessSearchResultControllerTopConstraintIdentifier){isCompleted in }
                    }
                }
            }
            
        } else if view.annotation is MKPlacemark{
            
            let placemark = view.annotation as! MKPlacemark
            latitude = placemark.coordinate.latitude
            longitude = placemark.coordinate.longitude
            
            view.image = #imageLiteral(resourceName: "addressMapItemCellPin").resizeImage(CGSize(width: 50.0, height: 50.0))
            if let _ = addressViewController{
                let mapItem = MKMapItem(placemark: view.annotation as! MKPlacemark)
                addressViewController.mapItem = mapItem
                NotificationCenter.default.post(name: Notification.Name(rawValue: NearByViewControllerNotificationIDs.addressViewControllerNeedsUpdate), object: self)
                animateToMiddleLimit(yVelocity: 500, and: ChildControllersUpperConstraints.addressViewControllerTopConstraint)
            } else {
                let mapItem = MKMapItem(placemark: view.annotation as! MKPlacemark)
                addAddressViewController(with: mapItem, and: currentUserLocation)
                if let _ = businessSearchResultTableController{
                    animateToMiddleLimit(yVelocity: 500, and: ChildControllersUpperConstraints.addressViewControllerTopConstraint)
                    animateToHidingLimit(yVelocity: 500, and: ChildControllersUpperConstraints.businessSearchResultControllerTopConstraintIdentifier){isCompleted in }
                }
            }
        }
        
        let region = MKCoordinateRegionMake(CLLocationCoordinate2D(latitude: latitude, longitude: longitude), mapView.region.span)
        mapView.setRegion(region, animated: true)
        
    }
    
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        if view.annotation is USRestStop {
            view.image = #imageLiteral(resourceName: "restStop").resizeImage(CGSize(width: 20.0, height: 20.0))
            
        } else if view.annotation is YelpBusinessAnnotation{
            view.image = #imageLiteral(resourceName: "yelpLocation").resizeImage(CGSize(width: 20.0, height: 20.0))
            
        } else if view.annotation is MKPlacemark{
            view.image = #imageLiteral(resourceName: "addressMapItemCellPin").resizeImage(CGSize(width: 20.0, height: 20.0))
            
        }
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        
        currentUserLocation = CLLocation(latitude: userLocation.coordinate.latitude, longitude: userLocation.coordinate.longitude)
        if shouldAddSearchTableView{
            let region = MKCoordinateRegionMakeWithDistance(currentUserLocation.coordinate, 8000, 8000)
            mapView.setRegion(region, animated: false)
            
            addChildBusinessSearchTableViewController()
            if let businessSearchResultTableController = businessSearchResultTableController{
                
                businessSearchResultTableController.currentUserLocation = currentUserLocation
            }
            animateToMiddleLimit(yVelocity: 500, and: ChildControllersUpperConstraints.businessSearchResultControllerTopConstraintIdentifier)
            shouldAddSearchTableView = false
        } else {
            businessSearchResultTableController.currentUserLocation = currentUserLocation
        }
    }
    
    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        if shouldAddSearchTableView{
            let limitedServiceAlert = UIAlertController(title: "Limited Service", message: "Please try again in a few moments.", preferredStyle: .alert)
            let action = UIAlertAction(title: "OK", style: .default, handler: nil)
            limitedServiceAlert.addAction(action)
            present(limitedServiceAlert, animated: true, completion: nil)
        }
    }
}

extension NearByViewController: BusinessSearchResultTableViewControllerDelegate{
    
    func businessSearchResultTableViewStartedGettingBusiness(_ searchResultTable: BusinessSearchResultTableViewController) {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        
    }
    
    func businessSearchResultTableViewStopedGettingBusiness(_ searchResultTable: BusinessSearchResultTableViewController, with searchResultList: [AnyObject], at currentLocation: CLLocationCoordinate2D){
    
        setUpMapView(with: searchResultList, and: currentLocation)
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        self.mapView.isHidden = false
    }
    
    func businessSearchResultTableViewDidSelectRow(_ searchResultTable: BusinessSearchResultTableViewController, with poi: AnyObject, and currentLocation: CLLocation) {
        
        var latitude: Double!
        var longitude: Double!
        
        if poi is USRestStop{
            
            let pointOfInterest = poi as! USRestStop
            latitude = pointOfInterest.latitude
            longitude = pointOfInterest.longitude
            
            addNearStaticRestStopDetailViewController(with: pointOfInterest)
            animateToMiddleLimit(yVelocity: 500, and: ChildControllersUpperConstraints.nearStaticRestStopDetailViewControllerTopConstraint)
            
        } else if poi is YLPBusiness{
            
            let yelpBusiness = poi as! YLPBusiness
            latitude = yelpBusiness.location.coordinate?.latitude
            longitude = yelpBusiness.location.coordinate?.longitude
            
            addBusinessDetailViewController(withBusinessID: yelpBusiness.identifier, and: currentLocation)
            animateToMiddleLimit(yVelocity: 500, and: ChildControllersUpperConstraints.businessDetailViewControllerTopConstraintIdentifier)
            
        } else if poi is MKMapItem{
            
            let mapItem = poi as! MKMapItem
            if let location = mapItem.placemark.location{
                latitude = location.coordinate.latitude
                longitude = location.coordinate.longitude
                
            }
            addAddressViewController(with: mapItem, and: currentLocation)
            animateToMiddleLimit(yVelocity: 500.0, and: ChildControllersUpperConstraints.addressViewControllerTopConstraint)
            
        } else if poi is HistoryUSRestStop{
            
            let historyUSRestStop = poi as! HistoryUSRestStop
            latitude = historyUSRestStop.latitude
            longitude = historyUSRestStop.longitude
            let fetchRequest = NSFetchRequest<USRestStop>()
            fetchRequest.entity = USRestStop.entity()
            
            do {
                
                let managedObjects = try managedObjectContext.fetch(fetchRequest)
                
                var restStop: USRestStop!
                
                for managedObject in managedObjects{
                    if managedObject.latitude == latitude && managedObject.longitude == longitude{
                        restStop = managedObject
                    }
                }
                
                if let restStop = restStop{
                    addNearStaticRestStopDetailViewController(with: restStop)
                    animateToMiddleLimit(yVelocity: 500, and: ChildControllersUpperConstraints.nearStaticRestStopDetailViewControllerTopConstraint)
                } else {
                    animateToMiddleLimit(yVelocity: 500, and: ChildControllersUpperConstraints.businessSearchResultControllerTopConstraintIdentifier)
                }
                
            } catch let error as NSError{
                print(error.debugDescription)
                print("*** Failed to fetch managed object to initiate history detail page!")
            }
        
        } else if poi is HistoryYelpBusiness{
            
            let historyYelpBusiness = poi as! HistoryYelpBusiness
            latitude = historyYelpBusiness.latitude
            longitude = historyYelpBusiness.longitude
            addBusinessDetailViewController(withBusinessID: historyYelpBusiness.businessIdentifier, and: currentLocation)
            animateToMiddleLimit(yVelocity: 500, and: ChildControllersUpperConstraints.businessDetailViewControllerTopConstraintIdentifier)
            
        } else if poi is FavoriteLocation{
            let favoriteLocation = poi as! FavoriteLocation
            let mapItem = MKMapItem(placemark: favoriteLocation.placemark)
            if let location = mapItem.placemark.location{
                latitude = location.coordinate.latitude
                longitude = location.coordinate.longitude
                setUpMapView(with: [favoriteLocation], and: CLLocationCoordinate2D(latitude: currentUserLocation.coordinate.latitude, longitude:currentUserLocation.coordinate.longitude))
            }
            addAddressViewController(with: mapItem, and: currentLocation)
            animateToMiddleLimit(yVelocity: 500.0, and: ChildControllersUpperConstraints.addressViewControllerTopConstraint)
        }
        
        mapView.deselectAnnotations(mapView.annotations)
        
        if let latitude = latitude, let longitude = longitude{
            if let selectedAnnotation = mapView.findAnnotationFor(latitude: latitude, longitude:
                longitude){
                mapView.selectAnnotation(selectedAnnotation, animated: true)
                let region = MKCoordinateRegionMake(CLLocationCoordinate2D(latitude: latitude, longitude: longitude), mapView.region.span)
                mapView.setRegion(region, animated: true)
            }
        }
        
        animateToHidingLimit(yVelocity: 500, and: ChildControllersUpperConstraints.businessSearchResultControllerTopConstraintIdentifier){isCompleted in }
    }
    
    func businessSearchResultTableViewControllerNeedsUpdatedMapRegion(_ searchResultTable: BusinessSearchResultTableViewController) -> MKCoordinateRegion {
        
        return mapView.region
    }
    
    func businessSearchResultTableViewControllerSearchBarDidBeginEditing(_ searchResultTable: BusinessSearchResultTableViewController) {
        animateToUpperLimit(yVelocity: 500, and: ChildControllersUpperConstraints.businessSearchResultControllerTopConstraintIdentifier)
        mapView.removeAnnotations(mapView.annotations)
    }

}

extension NearByViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateToLowerLimit(yVelocity: 500, and: ChildControllersUpperConstraints.businessSearchResultControllerTopConstraintIdentifier)
        
        animateToLowerLimit(yVelocity: 500, and: ChildControllersUpperConstraints.businessDetailViewControllerTopConstraintIdentifier)
        
    }
}



extension NearByViewController: BusinessDetailViewControllerDelegate{
    
    func terminateBusinessDetailViewController(){
        
        if let _ = businessDetailViewController{
            animateToHidingLimit(yVelocity: 500.0, and: ChildControllersUpperConstraints.businessDetailViewControllerTopConstraintIdentifier){isComplete in
                if isComplete{
                    self.businessDetailViewController.willMove(toParentViewController: self)
                    self.businessDetailViewController.removeFromParentViewController()
                    self.businessDetailViewController.view.removeFromSuperview()
                    self.businessDetailViewController = nil
                    self.animateToMiddleLimit(yVelocity: 500.0, and: ChildControllersUpperConstraints.businessSearchResultControllerTopConstraintIdentifier)
                    if self.businessSearchResultTableController.tableView.numberOfRows(inSection: 0) != 0 {
                        self.businessSearchResultTableController.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                    }
                }
            }
        }
    }
    
    func businessDetailViewControllerDidTapCloseButton(_ businessDetail: BusinessDetailViewController) {
        
        terminateBusinessDetailViewController()
        if let _ = businessSearchResultTableController{
            businessSearchResultTableController.searchBar.setShowsCancelButton(false, animated: true)
        }
        mapView.deselectAnnotations(mapView.annotations)
        
        
    }
    
    func businessDetailDidRequestUpdate(_ businessDetail: BusinessDetailViewController, business: Business) {
        
    }
    
    func businessDetailViewControllerDidUpdateUserLocation(_ businessDetail: BusinessDetailViewController, newUserLocation: CLLocation) {
        
        self.currentUserLocation = newUserLocation
        businessSearchResultTableController.currentUserLocation = newUserLocation
    }
}

extension NearByViewController: NearStaticRestStopDetailViewControllerDelegate{
    
    func terminateNearStaticRestStopDetailViewController(){
        animateToHidingLimit(yVelocity: 500.0, and: ChildControllersUpperConstraints.nearStaticRestStopDetailViewControllerTopConstraint){isCompleted in
            if isCompleted{
                
                self.nearStaticRestStopDetailViewController.willMove(toParentViewController: nil)
                self.nearStaticRestStopDetailViewController.removeFromParentViewController()
                self.nearStaticRestStopDetailViewController.view.removeFromSuperview()
                self.nearStaticRestStopDetailViewController = nil
                self.removeDimView()
                self.animateToMiddleLimit(yVelocity: 500.0, and: ChildControllersUpperConstraints.businessSearchResultControllerTopConstraintIdentifier)
                if self.businessSearchResultTableController.tableView.numberOfRows(inSection: 0) != 0 {
                    self.businessSearchResultTableController.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
            }
        }
    }
    
    func nearStaticRestStopDetailViewControllerDidTapCloseButton(_ nearStaticRestStopDetailViewController: NearStaticRestStopDetailViewController) {
        
        terminateNearStaticRestStopDetailViewController()
        if let _ = businessSearchResultTableController{
            businessSearchResultTableController.searchBar.setShowsCancelButton(false, animated: true)
        }
        mapView.deselectAnnotations(mapView.annotations)
        
        
    }
    
    func nearStaticRestStopDetailViewControllerDidRequestUpdate(_ narStaticRestStopDetailViewControllerwith: NearStaticRestStopDetailViewController, restStop: USRestStop) {
        
    }
}

extension NearByViewController: AddressViewControllerDelegate{
    
    func terminateAddressViewController(){
        
        animateToHidingLimit(yVelocity: 500.0, and: ChildControllersUpperConstraints.addressViewControllerTopConstraint){isComplete in
            if isComplete{
                self.addressViewController.willMove(toParentViewController: nil)
                self.addressViewController.removeFromParentViewController()
                self.addressViewController.view.removeFromSuperview()
                self.addressViewController = nil
                self.animateToMiddleLimit(yVelocity: 500.0, and: ChildControllersUpperConstraints.businessSearchResultControllerTopConstraintIdentifier)
                if self.businessSearchResultTableController.tableView.numberOfRows(inSection: 0) != 0 {
                    self.businessSearchResultTableController.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
                }
            }
        }
    }
    
    func addressViewControllerDidTapCloseButton(_ addressViewController: AddressViewController) {
        
        terminateAddressViewController()
        if let _ = businessSearchResultTableController{
            businessSearchResultTableController.searchBar.setShowsCancelButton(false, animated: true)
        }
        mapView.deselectAnnotations(mapView.annotations)
    }
}
