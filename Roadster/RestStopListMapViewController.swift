//
//  RestStopList2ViewController.swift
//  Roadster
//
//  Created by A Ja on 10/15/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

import UIKit
import MapKit
import CoreData


enum RouteBound: String{
    case NB = "NB"
    case SB = "SB"
    case EB = "EB"
    case WB = "WB"
    case NBandSB = "NB/SB"
    case SBandNB = "SB/NB"
    case EBandWB = "EB/WB"
}

class RestStopListMapViewController: UIViewController {
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var mapView: MKMapView!
    var NBlistOfRestStops:[USRestStop] = [USRestStop]()
    var SBlistOfRestStops:[USRestStop] = [USRestStop]()
    var EBlistOfRestStops:[USRestStop] = [USRestStop]()
    var WBlistOfRestStops:[USRestStop] = [USRestStop]()
    var NBPolyLineCoordinates = [CLLocationCoordinate2D]()
    var SBPolyLineCoordinates = [CLLocationCoordinate2D]()
    var EBPolyLineCoordinates = [CLLocationCoordinate2D]()
    var WBPolyLineCoordinates = [CLLocationCoordinate2D]()
    var listOfRestStops:[USRestStop]!
    var stateAbbreviation: String!
    var routeName: String!
    var managedObjectContext: NSManagedObjectContext!
    var states: States!
    var fullStateName:String!
    var childController: RestStopListChildTableViewController!
    var childControllerCurrentCenterPoint: CGPoint!
    var appWindow: UIWindow!
    var isViewFirstLoad = 1
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func loadView() {
        super.loadView()
        listOfRestStops = restStops(forContext: managedObjectContext)
        sortRestStopBound()
        NBlistOfRestStops = sortBasedOnLatitudeLongitude(forList: NBlistOfRestStops, forBound: .NB)
        SBlistOfRestStops = sortBasedOnLatitudeLongitude(forList: SBlistOfRestStops, forBound: .SB)
        EBlistOfRestStops = sortBasedOnLatitudeLongitude(forList: EBlistOfRestStops, forBound: .EB)
        WBlistOfRestStops = sortBasedOnLatitudeLongitude(forList: WBlistOfRestStops, forBound: .WB)
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
    
    
    func restStops(forContext context: NSManagedObjectContext) -> [USRestStop]{
        var array = [USRestStop]()
        let fetchRequest = NSFetchRequest<USRestStop>()
        let predicate = NSCompoundPredicate(format: "state == %@ AND routeName == %@", stateAbbreviation, routeName)
        fetchRequest.fetchBatchSize = 100
        fetchRequest.entity = USRestStop.entity()
        fetchRequest.predicate = predicate
        do{
            array = try managedObjectContext.fetch(fetchRequest)
        }catch let error as NSError{
            print(error.debugDescription)
            fatalError("Failed to fetch rest stops from the data store!")
        }
        return array
    }
    
    func sortRestStopBound(){
        if let listOfRestStops = listOfRestStops{
            for restStop in listOfRestStops{
                switch restStop.bound {
                case RouteBound.NB.rawValue:
                    NBlistOfRestStops.append(restStop)
                case RouteBound.SB.rawValue:
                    SBlistOfRestStops.append(restStop)
                case RouteBound.EB.rawValue:
                    EBlistOfRestStops.append(restStop)
                case RouteBound.WB.rawValue:
                    WBlistOfRestStops.append(restStop)
                case RouteBound.NBandSB.rawValue:
                    NBlistOfRestStops.append(restStop)
                    SBlistOfRestStops.append(restStop)
                case RouteBound.SBandNB.rawValue:
                    NBlistOfRestStops.append(restStop)
                    SBlistOfRestStops.append(restStop)
                case RouteBound.EBandWB.rawValue:
                    EBlistOfRestStops.append(restStop)
                    WBlistOfRestStops.append(restStop)
                case "NB ONLY":
                    NBlistOfRestStops.append(restStop)
                case "SB ONLY":
                    SBlistOfRestStops.append(restStop)
                case "EB ONLY":
                    EBlistOfRestStops.append(restStop)
                case "WB ONLY":
                    WBlistOfRestStops.append(restStop)
                default:
                    fatalError("Error sorting route bound in RestStopList2ViewController!")
                }
            }
        }
    }

    func sortBasedOnLatitudeLongitude(forList list: [USRestStop], forBound bound: RouteBound) -> [USRestStop]{
        var sortedList: [USRestStop] = [USRestStop]()
        switch bound{
        case .NB:
            sortedList = list.sorted(by: { restStop1, restStop2 in
                return restStop1.latitude < restStop2.latitude
            })
            for restStop in sortedList {
                NBPolyLineCoordinates.append(CLLocationCoordinate2D(latitude: restStop.latitude, longitude: restStop.longitude))
            }
        case .SB:
            sortedList = list.sorted(by: { restStop1, restStop2 in
                return restStop1.latitude > restStop2.latitude
            })
            for restStop in sortedList {
                SBPolyLineCoordinates.append(CLLocationCoordinate2D(latitude: restStop.latitude, longitude: restStop.longitude))
            }
        case .EB:
            sortedList = list.sorted(by: { restStop1, restStop2 in
                return restStop1.longitude < restStop2.longitude
            })
            for restStop in sortedList {
                EBPolyLineCoordinates.append(CLLocationCoordinate2D(latitude: restStop.latitude, longitude: restStop.longitude))
            }
        case .WB:
            sortedList = list.sorted(by: { restStop1, restStop2 in
                return restStop1.longitude > restStop2.longitude
            })
            for restStop in sortedList {
                WBPolyLineCoordinates.append(CLLocationCoordinate2D(latitude: restStop.latitude, longitude: restStop.longitude))
            }
        default:
            print("Sorting rest stops based on latitude and longitude failed!")
        }
        return sortedList
    }
    
    func setUpSegmentedControl(){
        if !NBlistOfRestStops.isEmpty || !SBlistOfRestStops.isEmpty {
            segmentedControl.setTitle("North Bound", forSegmentAt: 0)
            segmentedControl.setTitle("South Bound", forSegmentAt: 1)
        } else if !EBlistOfRestStops.isEmpty || !WBlistOfRestStops.isEmpty{
            segmentedControl.setTitle("East Bound", forSegmentAt: 0)
            segmentedControl.setTitle("West Bound", forSegmentAt: 1)
        }
        segmentedControl.addTarget(self, action: #selector(segmentedControlChangedValue), for: .valueChanged)
        segmentedControl.sizeToFit()
        segmentedControl.layer.backgroundColor = UIColor.white.cgColor
        addChildTableViewController()
    }
    
    func segmentedControlChangedValue(){
        
        if !NBlistOfRestStops.isEmpty || !SBlistOfRestStops.isEmpty {
            if segmentedControl.selectedSegmentIndex == 0 {
                childController.restStopList = NBlistOfRestStops
                childController.getRestStopDistanceFromUser()
                childController.bound = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)!
                mapView.removeAnnotations(mapView.annotations)
            } else {
                childController.restStopList = SBlistOfRestStops
                childController.getRestStopDistanceFromUser()
                childController.bound = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)!
                mapView.removeAnnotations(mapView.annotations)
            }
        } else if !EBlistOfRestStops.isEmpty || !WBlistOfRestStops.isEmpty{
            if segmentedControl.selectedSegmentIndex == 0 {
                childController.restStopList = EBlistOfRestStops
                childController.getRestStopDistanceFromUser()
                childController.bound = segmentedControl.titleForSegment(at: segmentedControl.selectedSegmentIndex)!
                mapView.removeAnnotations(mapView.annotations)
            } else {
                childController.restStopList = WBlistOfRestStops
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
        if !NBlistOfRestStops.isEmpty || !SBlistOfRestStops.isEmpty {
            if segmentedControl.selectedSegmentIndex == 0 {
                childController.restStopList = NBlistOfRestStops
            } else {
                childController.restStopList = SBlistOfRestStops
            }
        } else if !EBlistOfRestStops.isEmpty || !WBlistOfRestStops.isEmpty{
            if segmentedControl.selectedSegmentIndex == 0 {
                childController.restStopList = EBlistOfRestStops
            } else {
                childController.restStopList = WBlistOfRestStops
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
    
    func setMapViewTo100KMRegion(for restStop: USRestStop){
        let region = MKCoordinateRegionMakeWithDistance(restStop.coordinate, 100000, 100000)
        mapView.setRegion(region, animated: true)
    }
    
    func setMapViewRegionWithCurrentSpan(for restStop: USRestStop){
        var region = mapView.region
        region.center = restStop.coordinate
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
        
        if isViewFirstLoad == 1 {
            setMapViewTo100KMRegion(for: restStop)
            isViewFirstLoad = 0
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
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotation")
        let rightButton = UIButton(type: UIButtonType.detailDisclosure)
        if annotationView == nil {
            annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
            annotationView?.tintColor = UIColor.brown
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = rightButton
        } else {
            annotationView?.annotation = annotation
            annotationView?.tintColor = UIColor.brown
            annotationView?.canShowCallout = true
            annotationView?.rightCalloutAccessoryView = rightButton
        }
        return annotationView
    }
    
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let sender = control as! UIButton
        mapView.deselectAnnotation(view.annotation, animated: true)
        performSegue(withIdentifier: "showDetailDisclosurePage", sender: sender)
    }
    
}









