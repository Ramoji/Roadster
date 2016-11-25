//
//  PinViewController.swift
//  Roadster
//
//  Created by A Ja on 11/22/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

import UIKit
import CoreData
import MapKit
import AudioToolbox

class PinViewController: UIViewController {
    
    var managedObjectContext: NSManagedObjectContext!
    @IBOutlet weak var mapView: MKMapView!
    var longPressGR: UILongPressGestureRecognizer!
    var longPressGRCount = 1
    var pinAnnotation: MKAnnotation!
    var pinCoordinate: CLLocationCoordinate2D!
    var mangedObjectContext: NSManagedObjectContext!
    var restStopsNearPin: [USRestStop] = [USRestStop]()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.isUserInteractionEnabled = true
        configureGestureRecognizer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func configureGestureRecognizer(){
        longPressGR = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        longPressGR.numberOfTapsRequired = 0
        longPressGR.numberOfTouchesRequired = 1
        longPressGR.minimumPressDuration = 0.5
        longPressGR.delaysTouchesBegan = true
        longPressGR.delegate = self
        mapView.addGestureRecognizer(longPressGR)
    }
   
    func handleLongPress(){
        
        longPressGRCount = longPressGRCount + 1
        
        switch longPressGR.state{
        case .began:
            AudioServicesPlaySystemSound(1520)
            let pin = longPressGR.location(in: self.view)
            getRestStops(near: pin)
            print("Longpress gesture recognizer began!")
            print("*******")
        case .cancelled:
            print("Longpress gesture recognizer was canceled!")
            print("*******")
        case .changed:
            print("Longpress gesture recognizer was changed!")
            print(longPressGRCount)
            print("*******")
        case  .ended:
            print("Longpress gesture recognizer ended!")
            print("*******")
        case .failed:
            print("The gesture recognizer failed!")
        default:
            print("Other states!")
            print("*******")
        }
        
    }
    
    func getRestStops(near pin: CGPoint){
        if !mapView.annotations.isEmpty{
            mapView.removeAnnotation(pinAnnotation)
            mapView.removeAnnotations(restStopsNearPin)
        }
        pinCoordinate = mapView.convert(pin, toCoordinateFrom: self.view)
        let region = MKCoordinateRegionMakeWithDistance(pinCoordinate, 80000, 80000)
        mapView.setRegion(region, animated: true)
        pinAnnotation = PinRestStopAnnotation(pinCoordinate: pinCoordinate)
        mapView.addAnnotation(pinAnnotation)
        restStopsNearPin = fetchRestStops(closeTo: pinCoordinate)
        mapView.addAnnotations(restStopsNearPin)
    }
    
    func fetchRestStops(closeTo pinCoordinate: CLLocationCoordinate2D) -> [USRestStop]{
        let restStops: [USRestStop]!
        let region = MKCoordinateRegionMakeWithDistance(pinCoordinate, 80000, 80000)
        let minCoordinate = CLLocationCoordinate2D(latitude: pinCoordinate.latitude - (region.span.latitudeDelta * 0.5), longitude: pinCoordinate.longitude - (region.span.longitudeDelta * 0.5))
        let maxCoordinate = CLLocationCoordinate2D(latitude: pinCoordinate.latitude + (region.span.latitudeDelta * 0.5), longitude: pinCoordinate.longitude + (region.span.longitudeDelta * 0.5))
        
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "USRestStop")
        let entity = NSEntityDescription.entity(forEntityName: "USRestStop", in: managedObjectContext)
        fetchRequest.entity = entity
        let predicate1 = NSPredicate(format: "latitude BETWEEN {%@, %@}", argumentArray: [minCoordinate.latitude, maxCoordinate.latitude])
        let predicate2 = NSPredicate(format: "longitude BETWEEN {%@, %@}", argumentArray: [minCoordinate.longitude, maxCoordinate.longitude])
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2])
        fetchRequest.predicate = compoundPredicate
        fetchRequest.fetchBatchSize = 20
        
        do{
            restStops = try managedObjectContext.fetch(fetchRequest) as! [USRestStop]
            for restStop in restStopsNearPin{
                print(restStop)
            }
        } catch let error as NSError{
            print(error.debugDescription)
            fatalError("Faile to fetch restStops near pinned location!")
        }
        
        return restStops
    }
}

extension PinViewController: UIGestureRecognizerDelegate{}
