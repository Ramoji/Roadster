//
//  MapViewController.swift
//  Roadster
//
//  Created by A Ja on 9/7/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    var states: States!
    var stateName: String!
    @IBOutlet weak var myNavigationBar: UINavigationBar!


    override func viewDidLoad() {
        super.viewDidLoad()
    
        
        if let stateName = stateName{
            
            let stateCenter = states.stateGeographicCenter(forState: stateName)
            let stateCenterSpanInMeters = states.stateCenteredLocationSpanInMeters(forState: stateName)
            let region = MKCoordinateRegionMakeWithDistance(stateCenter, stateCenterSpanInMeters.0, stateCenterSpanInMeters.1)
            mapView.setRegion(region, animated: true)
            mapView.addAnnotation(MapViewController())
            mapView.delegate = self
            
        }

        // Do any additional setup after loading the view.
    }
    
    override func viewWillLayoutSubviews() {
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(){
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func done() {
        dismiss(animated: true, completion: nil)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension MapViewController: UIBarPositioningDelegate{
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return UIBarPosition.topAttached
    }
}

extension MapViewController: MKAnnotation{
    
    var coordinate: CLLocationCoordinate2D {
        if let stateName = stateName{
            return states.stateGeographicCenter(forState: stateName)
        } else {
            return CLLocationCoordinate2D.init(latitude: 0, longitude: 0)
        }
    }
}

extension MapViewController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotation")
        return annotationView
    }
}


    

