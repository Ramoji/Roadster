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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listOfRestStops = restStops(forContext: managedObjectContext)
        sortRestStopBound()
        NBlistOfRestStops = sortBasedOnLatitudeLongitude(forList: NBlistOfRestStops, forBound: .NB)
        SBlistOfRestStops = sortBasedOnLatitudeLongitude(forList: SBlistOfRestStops, forBound: .SB)
        EBlistOfRestStops = sortBasedOnLatitudeLongitude(forList: EBlistOfRestStops, forBound: .EB)
        WBlistOfRestStops = sortBasedOnLatitudeLongitude(forList: WBlistOfRestStops, forBound: .WB)
        setUpSegmentedControl()
        mapView.delegate = self
        for restStop in listOfRestStops{
            print(restStop.bound)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                mapView.removeAnnotations(mapView.annotations)
            } else {
                childController.restStopList = SBlistOfRestStops
                mapView.removeAnnotations(mapView.annotations)
            }
        } else if !EBlistOfRestStops.isEmpty || !WBlistOfRestStops.isEmpty{
            if segmentedControl.selectedSegmentIndex == 0 {
                childController.restStopList = EBlistOfRestStops
                mapView.removeAnnotations(mapView.annotations)
            } else {
                childController.restStopList = WBlistOfRestStops
                mapView.removeAnnotations(mapView.annotations)
            }
        }
        childController.tableView.reloadData()
        childController.selectFirstRow()
    }
    
    func addChildTableViewController(){
        
        childController = storyboard?.instantiateViewController(withIdentifier: "tableController") as! RestStopListChildTableViewController
        childController.view.frame = CGRect(x: 0, y: view.bounds.size.height - ((self.tabBarController?.tabBar.frame.size.height)! + 196), width: view.bounds.size.width, height: 198)
        childController.view.layer.cornerRadius = 10
        childController.view.clipsToBounds = true
        view.addSubview((childController.view)!)
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
    
    
    deinit {
        print("RestStopListMapViewController has deallocated!")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "showDetailDisclosurePage" {
            let annotations = mapView.annotations as! [USRestStop]
            let detailDisclosureViewController = segue.destination as! RestStopDetailDisclosureViewController
            if !annotations.isEmpty{
                detailDisclosureViewController.delegate = self
                let restStop = annotations[0]
                detailDisclosureViewController.restStop = restStop
                detailDisclosureViewController.states = states
                detailDisclosureViewController.fullStateName = fullStateName
                if appWindow.bounds.size.height <= 568.0{
                    setMapView80KMRegionSmallerScreen(restStop: restStop)
                } else {
                    setMapView80KMRegion(restStop: restStop)
                }
                childControllerCurrentCenterPoint = childController.view.center
                UIView.animate(withDuration: 0.3, animations: {
                    self.childController.view.center.y = self.childController.view.center.y * 1.5
                })
            } else {
                return
            }
        }
    }
    
    func setMapView80KMRegion(restStop: USRestStop){
        let preCoordinates = CLLocationCoordinate2D(latitude: restStop.latitude, longitude: restStop.longitude)
        let preRegion = MKCoordinateRegionMakeWithDistance(preCoordinates, 800, 800)
        let finalCoordinates = CLLocationCoordinate2D(latitude: restStop.latitude - (preRegion.span.latitudeDelta * 0.25), longitude: restStop.longitude)
        let finalRegion = MKCoordinateRegionMakeWithDistance(finalCoordinates, 800, 800)
        mapView.setRegion(finalRegion, animated: true)
    }
    
    func setMapView100KMRegion(restStop: USRestStop){
        let preRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: restStop.latitude, longitude: restStop.longitude), 80467, 80467)
        let finalRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: restStop.latitude - (preRegion.span.latitudeDelta * 0.30), longitude: restStop.longitude), 100000, 100000)
        mapView.setRegion(finalRegion, animated: true)
    }
    
    func setMapView80KMRegionSmallerScreen(restStop: USRestStop){
        let preCoordinates = CLLocationCoordinate2D(latitude: restStop.latitude, longitude: restStop.longitude)
        let preRegion = MKCoordinateRegionMakeWithDistance(preCoordinates, 800, 800)
        let finalCoordinates = CLLocationCoordinate2D(latitude: restStop.latitude - (preRegion.span.latitudeDelta * 0.20), longitude: restStop.longitude)
        let finalRegion = MKCoordinateRegionMakeWithDistance(finalCoordinates, 800, 800)
        mapView.setRegion(finalRegion, animated: true)
    }
    
    func setMapView100KMRegionSmallerScreen(restStop: USRestStop){
        let preRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: restStop.latitude, longitude: restStop.longitude), 80467, 80467)
        let finalRegion = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: restStop.latitude - (preRegion.span.latitudeDelta * 0.33), longitude: restStop.longitude), 100000, 100000)
        mapView.setRegion(finalRegion, animated: true)
    }
}

extension RestStopListMapViewController: RestStopListChildTableViewControllerDelegate{
    func restStopListTable(_ childTableViewController: RestStopListChildTableViewController, didPickRestStop restStop: USRestStop) {
        let annotations = mapView.annotations
        mapView.removeAnnotations(annotations)
        mapView.addAnnotation(restStop)
        if appWindow.bounds.size.height <= 568.0 {
            setMapView100KMRegionSmallerScreen(restStop: restStop)
        } else {
            setMapView100KMRegion(restStop: restStop)
        }
        
        
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

extension RestStopListMapViewController: RestStopDetailDisclosureViewControllerDelegate{
    func restStopDetailDisclosureDidClose(_ viewController: RestStopDetailDisclosureViewController) {
        mapView.mapType = MKMapType.standard
        UIView.animate(withDuration: 0.3, animations: {
            self.childController.view.center.y = self.childControllerCurrentCenterPoint.y
        })
        let annotations = mapView.annotations
        if annotations.count != 0 {
            let restStop = annotations[0] as! USRestStop
            if appWindow.bounds.size.height <= 568.0{
                setMapView100KMRegionSmallerScreen(restStop: restStop)
            } else {
                setMapView100KMRegion(restStop: restStop)
            }
        }
    }
    
    func restStopDetailDisclosureDidPick(_ viewController: RestStopDetailDisclosureViewController, mapType type: MKMapType) {
    
        mapView.mapType = type
    }
}







