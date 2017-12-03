//
//  AddressViewController.swift
//  Roadster
//
//  Created by EA JA on 8/28/17.
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit
import MapKit

protocol PinnedAddressViewControllerDelegate {
    func pinnedAddressViewControllerDidTapCloseButton(_ addressTableViewController: PinnedAddressViewController)
}

class PinnedAddressViewController: UIViewController {
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var mapView: MKMapView!
    var pinnedAddressTableViewController: PinnedAddressTableViewController!
    var mapItem: MKMapItem!
    var currentUserLocation: CLLocation!
    var delegate: PinnedAddressViewControllerDelegate?
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        
        mapView.addAnnotation(mapItem.placemark)
        mapView.isUserInteractionEnabled = false
        let region = MKCoordinateRegionMakeWithDistance(mapItem.placemark.coordinate, 1500, 1500)
        mapView.setRegion(region, animated: true)
        
        
        view.addShadow(withCornerRadius: 15.0)
        
        
        
        closeButton.setImage(#imageLiteral(resourceName: "closeButton").resizeImage(CGSize(width: 20.0, height: 20.0)).withRenderingMode(.alwaysOriginal), for: .normal)
        
        var addressString = ""
        
        if let subThoroughfare = mapItem.placemark.subThoroughfare{
            addressString = subThoroughfare
        }
        
        if let thoroughfare = mapItem.placemark.thoroughfare{
            addressString += " " + thoroughfare
        }
        
        addressLabel.text = addressString
        
        if let addressCLLocation = mapItem.placemark.location{
            let distanceFromUser = currentUserLocation.distance(from: addressCLLocation) / 1609.0
            distanceLabel.text = String(format: "%.1f", distanceFromUser) + " mi"
        }
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let blurView = BlurredBackgroundView(frame: view.bounds, addBackgroundPic: true)
        blurView.layer.masksToBounds = true
        blurView.layer.cornerRadius = 15.0
        view.addSubview(blurView)
        view.sendSubview(toBack: blurView)
        
        view.setNeedsLayout()
    }
    
    
    
    
    @IBAction func close(_ sender: UIButton){
        
        
        
        delegate?.pinnedAddressViewControllerDidTapCloseButton(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "PinnedAddressTableViewControllerSegue"{
            pinnedAddressTableViewController = segue.destination as! PinnedAddressTableViewController
            pinnedAddressTableViewController.mapItem = mapItem
            pinnedAddressTableViewController.currentUserLocation = currentUserLocation
        }
    }
    
    
    
}

