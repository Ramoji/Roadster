//
//  StaticDetailTableViewController.swift
//  Roadster
//
//  Created by A Ja on 11/27/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

import UIKit
import MapKit

class StaticDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var imageViewOne: UIImageView!
    @IBOutlet weak var imageViewTwo: UIImageView!
    @IBOutlet weak var imageViewThree: UIImageView!
    @IBOutlet weak var imageViewFour: UIImageView!
    @IBOutlet weak var imageViewFive: UIImageView!
    @IBOutlet weak var imageViewSix: UIImageView!
    @IBOutlet weak var imageViewSeven: UIImageView!
    @IBOutlet weak var imageViewEight: UIImageView!
    @IBOutlet weak var imageViewNine: UIImageView!
    @IBOutlet weak var imageViewTen: UIImageView!
    var imageViews: [UIImageView]!
    
    @IBOutlet weak var facilitiesLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var parkingImageView: UIImageView!
    @IBOutlet weak var truck: UIImageView!
    @IBOutlet weak var sedanCar: UIImageView!
    @IBOutlet weak var trailer: UIImageView!
    
    var restStop: USRestStop!
    var fullStateName: String!
    var bound = ""
    let blurredBackgroudView = BlurredBackgroundView(frame: CGRect.zero, addBackgroundPic: true)
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSegmentedControl()
        navigationItem.title = restStop.stopName
        setUpViewForRestStop()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor.clear
        tableView.backgroundView = blurredBackgroudView
        setUpTableView()
    }
    
    override func loadView() {
        super.loadView()
        imageViews = [imageViewOne, imageViewTwo, imageViewThree, imageViewFour, imageViewFive, imageViewSix, imageViewSeven, imageViewEight, imageViewNine, imageViewTen]
    }
    
    func setUpTableView(){
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func setUpSegmentedControl(){
        segmentedControl.addTarget(self, action: #selector(handleSegmentChange), for: UIControlEvents.valueChanged)
    }
    
    func handleSegmentChange(){
        if segmentedControl.selectedSegmentIndex == 0{
            mapView.mapType = MKMapType.standard
        } else {
            mapView.mapType = MKMapType.hybrid
        }
    }
    
    func setUpViewForRestStop(){
        let iconSize = CGSize(width: 25.0, height: 25.0)
        let vehicleIconSize = CGSize(width: 25.0, height: 25.0)
        prepIconViews()
        if let restStop = restStop, let fullStateName = fullStateName{
            titleLabel.text = "Rest Stop on \((restStop.routeName as NSString)) in \(fullStateName.capitalized)"
            mapView.addAnnotation(restStop)
            latitudeLabel.text =  restStop.latitude.convertToString()
            longitudeLabel.text = restStop.longitude.convertToString()
            parkingImageView.image = UIImage(named: "parking")?.resizeImage(iconSize)
            sedanCar.image = UIImage(named: "sedan")?.resizeImage(iconSize)
            if restStop.rvDump{
                trailer.image = UIImage(named: "rvDump")?.resizeImage(vehicleIconSize)
            }
            if !restStop.noTrucks{
                truck.image = UIImage(named: "truck")?.resizeImage(vehicleIconSize)
            }
            parkingImageView.image = UIImage(named: "parking")?.resizeImage(iconSize)
            
            
            
        }
        setUpMapView()
        configureFacilityIcons()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("***Receiving Memory Warning from StaticDetailTableViewController!")
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    func setUpMapView(){
        if let restStop = restStop{
            let region = MKCoordinateRegionMakeWithDistance(restStop.coordinate, 500, 500)
            mapView.setRegion(region, animated: true)
            mapView.isUserInteractionEnabled = false
        }
    }
    
    private func prepIconViews(){
        //facilitiesLabel.backgroundColor = UIColor.clear
        //facilitiesLabel.text = ""
        for imageView in imageViews{
            imageView.isHidden = true
            imageView.image = nil
        }
    }
    
    private func configureFacilityIcons(){
        let facilites = getAvailableFacilities(from: restStop)
        for (index, facility) in facilites.enumerated(){
            let imageSize = CGSize(width: 20.0, height: 20.0)
            let facilityImageView = imageViews![index]
            facilityImageView.isHidden = false
            facilityImageView.image = UIImage(named: facility)?.resizeImage(imageSize)
        }
    }
    
    private func getAvailableFacilities(from restStop: USRestStop) -> [String]{
        
        var facilites: [String] = []
        
        if restStop.drinkingWater {
            facilites.append("drinkingWater")
        }
        if restStop.foodRest {
            facilites.append("restaurant")
        }
        if restStop.gas {
            facilites.append("gas")
        }
        
        if restStop.handicappedFacilities{
            facilites.append("handicappedFacilites")
        }
        
        if restStop.petArea{
            facilites.append("petArea")
        }
        if restStop.phone{
            facilites.append("phone")
        }
        if restStop.picnicTables{
            facilites.append("picnicTable")
        }
        if restStop.restRoom{
            facilites.append("restroom")
        }
        if restStop.vMachine{
            facilites.append("vendingMachine")
        }
        
        return facilites
    }

}

extension StaticDetailTableViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let anotationSize = CGSize(width: 30.0, height: 30.0)
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotationView")
            annotationView?.image = UIImage(named: "restStop")?.resizeImage(anotationSize)
        }
        annotationView!.annotation = annotation
        return annotationView
    }
}



