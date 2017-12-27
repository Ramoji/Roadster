
//  Copyright © 2016 A Ja. All rights reserved.
//

import UIKit
import MapKit
import CoreData


class RestStopListMapViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    var state: String!
    var route: String!
    var routeClassification: String = ""
    var managedObjectContext: NSManagedObjectContext!
    var fullStateName:String!
    var childController: RestStopListChildTableViewController!
    var childControllerCurrentCenterPoint: CGPoint!
    var appWindow: UIWindow!
    var isViewFirstLoad = true
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let route = route {
            navigationItem.title = route
        }
    }
    
    override func loadView() {
        super.loadView()
        routeClassification = POIProvider.getRouteClassification(inState: state, onRoute: route)
        setUpSegmentedControl()
        setUpActivityIndicator()
        view.setNeedsLayout()
        mapView.delegate = self
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("***Receiving Memory Warning from RestStopListMapViewController!")
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    func setUpActivityIndicator(){
        activityIndicator.center = view.center
        view.addSubview(activityIndicator)
        view.setNeedsLayout()
        mapView.isHidden = true
        childController.view.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator(){
        
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        mapView.isHidden = false
        childController.view.isHidden = false
        activityIndicator.removeFromSuperview()
    }
    
    func setUpSegmentedControl(){
        
        if routeClassification == PossibleDirections.northSouthRoute{
            segmentedControl.setTitle("North Bound", forSegmentAt: 0)
            segmentedControl.setTitle("South Bound", forSegmentAt: 1)
        } else if routeClassification == PossibleDirections.eastWestRoute{
            segmentedControl.setTitle("East Bound", forSegmentAt: 0)
            segmentedControl.setTitle("West Bound", forSegmentAt: 1)
        }
        segmentedControl.addTarget(self, action: #selector(segmentedControlChangedValue), for: .valueChanged)
        segmentedControl.sizeToFit()
        segmentedControl.layer.backgroundColor = UIColor.white.cgColor
        addChildTableViewController()
    }
    
    func segmentedControlChangedValue(){
        
        if routeClassification == PossibleDirections.northSouthRoute{
            if segmentedControl.selectedSegmentIndex == 0 {
                childController.restStopList = POIProvider.getRestStops(inState: state, onRoute: route, forDirection: PossibleDirections.northBound)
                childController.getRestStopDistanceFromUser()
                childController.bound = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)!
                mapView.removeAnnotations(mapView.annotations)
            } else {
                childController.restStopList = POIProvider.getRestStops(inState: state, onRoute: route, forDirection: PossibleDirections.southBound)
                childController.getRestStopDistanceFromUser()
                childController.bound = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)!
                mapView.removeAnnotations(mapView.annotations)
            }
            
        } else if routeClassification == PossibleDirections.eastWestRoute{
            if segmentedControl.selectedSegmentIndex == 0 {
                childController.restStopList = POIProvider.getRestStops(inState: state, onRoute: route, forDirection: PossibleDirections.eastBound)
                childController.getRestStopDistanceFromUser()
                childController.bound = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)!
                mapView.removeAnnotations(mapView.annotations)
            } else {
                childController.restStopList = POIProvider.getRestStops(inState: state, onRoute: route, forDirection: PossibleDirections.westBound)
                childController.getRestStopDistanceFromUser()
                childController.bound = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)!
                mapView.removeAnnotations(mapView.annotations)
            }
        }
        childController.mapViewDidChangeBound()
    }
    
    func addChildTableViewController(){
       
        childController = storyboard?.instantiateViewController(withIdentifier: "tableController") as! RestStopListChildTableViewController
        childController.fullStateName = fullStateName
        childController.bound = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)!
        childController.view.clipsToBounds = true
        view.addSubview((childController.view)!)
        
        childController.view.translatesAutoresizingMaskIntoConstraints = false
        let childControllerTopAnchor = childController.view.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -15)
        let childControllerTrailingAnchor = childController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        let childControllerLeadingAnchor = childController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let childControllerBottomAnchor = childController.view.bottomAnchor.constraint(equalTo: bottomLayoutGuide.topAnchor)
        
        NSLayoutConstraint.activate([childControllerTopAnchor, childControllerTrailingAnchor, childControllerLeadingAnchor, childControllerBottomAnchor])
        
        addChildViewController(childController)
        childController.didMove(toParentViewController: self)
        childController.delegate = self
        
        switch routeClassification {
        case PossibleDirections.northSouthRoute:
            if segmentedControl.selectedSegmentIndex == 0 {
                childController.restStopList = POIProvider.getRestStops(inState: state, onRoute: route, forDirection: PossibleDirections.northBound)
            } else {
                childController.restStopList = POIProvider.getRestStops(inState: state, onRoute: route, forDirection: PossibleDirections.southBound)
            }
        case PossibleDirections.eastWestRoute:
            if segmentedControl.selectedSegmentIndex == 0 {
                childController.restStopList = POIProvider.getRestStops(inState: state, onRoute: route, forDirection: PossibleDirections.eastBound)
            } else {
                childController.restStopList = POIProvider.getRestStops(inState: state, onRoute: route, forDirection: PossibleDirections.westBound)
            }
            
        default:
            print("*** Unsupported route classification!")
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    func setMapViewTo100KMRegion(for restStop: USRestStop){
        
        var region = MKCoordinateRegionMakeWithDistance(restStop.coordinate, 100000, 100000)
        region.center = restStop.coordinate
        mapView.setRegion(region, animated: true)
    }
    
    func setMapViewRegionWithCurrentSpan(for restStop: USRestStop){
        //Calculating span in meters because creating a region based on current span is affected by topography
        let extremeLeftPoint = CLLocation(latitude: mapView.centerCoordinate.latitude - mapView.region.span.latitudeDelta * 0.5, longitude: mapView.centerCoordinate.longitude)
        let extremeRightPoint = CLLocation(latitude: mapView.centerCoordinate.latitude + mapView.region.span.latitudeDelta * 0.5, longitude: mapView.centerCoordinate.longitude)
        var distance = extremeLeftPoint.distance(from: extremeRightPoint)
        let distanceInInt = Int(distance) // to truncate any numbers after the decimal
        distance = CLLocationDistance(distanceInInt)
        let region = MKCoordinateRegionMakeWithDistance(restStop.coordinate, distance, distance)
        mapView.setRegion(region, animated: true)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        
    }
    
    deinit {
        print("***RestStopListMapViewController has deallocated!")
        
    }
}

extension RestStopListMapViewController: RestStopListChildTableViewControllerDelegate{
    
    func restStopListTable(_ childTableViewController: RestStopListChildTableViewController, didPickRestStop restStop: USRestStop) {
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
        mapView.addAnnotation(restStop)
        
        if isViewFirstLoad{
            setMapViewTo100KMRegion(for: restStop)
            isViewFirstLoad = false
        } else {
            setMapViewRegionWithCurrentSpan(for: restStop)
        }
    }
    
    func restStopListTable(_ childTableViewController: RestStopListChildTableViewController, didFindUserLocation: CLLocation) {
        hideActivityIndicator()
    }
    
    func restStopListTableDidNotFindLocation(_ childTableViewController: RestStopListChildTableViewController) {
        let alert = UIAlertController(title: "Weak GPS signal!", message: "Could not get user location. Please try again in a few minutes.", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler: {
            dismissAction in
            self.dismiss(animated: true, completion: nil)
        })
        alert.addAction(dismissAction)
        present(alert, animated: true, completion: nil)
    }
}

extension RestStopListMapViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let annotationViewImageSize = CGSize(width: 30.0, height: 30.0)
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotation")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
            annotationView?.image = UIImage(named: "restStop")?.resizeImage(annotationViewImageSize)
        } else {
            annotationView?.annotation = annotation
            annotationView?.image = UIImage(named: "restStop")?.resizeImage(annotationViewImageSize)
        }
        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let sender = control as! UIButton
        mapView.deselectAnnotation(view.annotation, animated: true)
        performSegue(withIdentifier: "showDetailDisclosurePage", sender: sender)
    }
    
}
