
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit
import MapKit

protocol AddressViewControllerDelegate {
    func addressViewControllerDidTapCloseButton(_ addressTableViewController: AddressViewController)
}

class AddressViewController: UIViewController {
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    var addressTableViewController: AddressTableViewController!
    var mapItem: MKMapItem!
    var currentUserLocation: CLLocation!
    var delegate: AddressViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(needsUpdate), name: Notification.Name(rawValue: NearByViewControllerNotificationIDs.addressViewControllerNeedsUpdate), object: nil)
        view.addShadow(withCornerRadius: 15.0)
       setUpView()
    }
    
    func setUpView(){
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
    
    func needsUpdate(){
        if let addressTableViewController = addressTableViewController{
            addressTableViewController.mapItem = mapItem
            addressTableViewController.currentUserLocation = currentUserLocation
            addressTableViewController.needsUpdate()
        }
        setUpView()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        needsUpdate()
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
    
        delegate?.addressViewControllerDidTapCloseButton(self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "addressTableViewControllerSegue"{
            addressTableViewController = segue.destination as! AddressTableViewController
            addressTableViewController.mapItem = mapItem
            addressTableViewController.currentUserLocation = currentUserLocation
        }
    }
}
