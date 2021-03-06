
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation





class PinnedAddressTableViewController: UITableViewController {
    
    
    @IBOutlet weak var directionButton: UIButton!
    @IBOutlet weak var addressTextView: UITextView!
    @IBOutlet weak var exportButton: UIButton!
    var mapItem: MKMapItem!
    var currentUserLocation: CLLocation!
    var directions: MKDirections!
    var favoriteLocations: [FavoriteLocation] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadFavoriteLocationsList()
        tableView.backgroundColor = UIColor.clear
        addressTextView.backgroundColor = UIColor.clear
        addressTextView.isSelectable = false
        addressTextView.isScrollEnabled = false
        prepTableView()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func prepTableView(){
        
        getEstimatedTravelTime()
        
        exportButton.setImage(#imageLiteral(resourceName: "export").resizeImage(CGSize(width: 20.0, height: 20.0)).withRenderingMode(.alwaysOriginal), for: .normal)
        
        
        var addressString = ""
        
        if let subThoroughfare = mapItem.placemark.subThoroughfare{
            addressString = subThoroughfare
        }
        
        if let thoroughfare = mapItem.placemark.thoroughfare{
            addressString += " " + thoroughfare
        }
        
        if let city = mapItem.placemark.locality{
            addressString += ", " + city
        }
        
        if let state = mapItem.placemark.administrativeArea{
            addressString += ", " + state
        }
        
        if let postalCode = mapItem.placemark.postalCode{
            addressString += " " + postalCode
        }
        
        if let country = mapItem.placemark.country{
            addressString += ", " + country
        }
        
        addressTextView.text = addressString
        
    }
    
    
    func getEstimatedTravelTime(){
        
        guard currentUserLocation != nil else {return}
        
        let directionsRequest = MKDirectionsRequest()
        let startPlacemartk = MKPlacemark(coordinate: currentUserLocation.coordinate)
        directionsRequest.source = MKMapItem(placemark: startPlacemartk)
        directionsRequest.destination = mapItem
        directions = MKDirections(request: directionsRequest)
        directions.calculateETA{estimatedTravelTimeResponse, error in
            if error == nil{
                if let estimatedTravelTimeResponse = estimatedTravelTimeResponse{
                    let expectedTravelTimeString = String(describing: Int(round(estimatedTravelTimeResponse.expectedTravelTime / 60)))
                    let buttonTitle = "Directions (\(expectedTravelTimeString) min drive)"
                    let buttonTitleNSString = NSString(string: buttonTitle)
                    let buttonTitleDirectionsRange = buttonTitleNSString.range(of: "Directions")
                    let buttonTitleTravelTimeRange = buttonTitleNSString.range(of: "(\(expectedTravelTimeString) min drive)")
                    let mutableAttributedTitleString = NSMutableAttributedString(string: buttonTitle)
                    mutableAttributedTitleString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: 15), range: buttonTitleDirectionsRange)
                    mutableAttributedTitleString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 13), range: buttonTitleTravelTimeRange)
                    self.directionButton.titleLabel?.numberOfLines = 2
                    self.directionButton.titleLabel?.textAlignment = .center
                    self.directionButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                    self.directionButton.setAttributedTitle(mutableAttributedTitleString, for: UIControlState.normal)
                    self.directionButton.setNeedsLayout()
                    
                }
            }
        }
    }
    
    
    @IBAction func navigate(_ sender: UIButton){
        if let mapItem = mapItem{
            mapItem.openInMaps(launchOptions: nil)
        }
    }
    
    func addToFavorite(){
        
        guard !doesMapItemExistInFavoriteLocationsList() else {
            
            removeMapItemFromFavoriteList()
            tableView.reloadData()
            
            return
        }
        
        let locationNameAlert = UIAlertController(title: "Location Name", message: "Please enter a name for this location", preferredStyle: .alert)
        locationNameAlert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Enter name"
            textField.clearButtonMode = .always
        })
        
        let saveAction = UIAlertAction(title: "Save", style: .default){action in
            if let textField = locationNameAlert.textFields?.first{
                if let locationName = textField.text{
                    let favoriteLocation = FavoriteLocation(placemark: self.mapItem.placemark, locationName: locationName)
                    self.favoriteLocations.append(favoriteLocation)
                } else {
                    let favoriteLocation = FavoriteLocation(placemark: self.mapItem.placemark, locationName: nil)
                    self.favoriteLocations.append(favoriteLocation)
                }
                
                self.saveFavoriteLocationsList()
                self.tableView.reloadData()
            }
        }
        
        locationNameAlert.addAction(saveAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        locationNameAlert.addAction(cancelAction)
        
        present(locationNameAlert, animated: true, completion: nil)
        
        
        
    }
    
    func doesMapItemExistInFavoriteLocationsList() -> Bool{
        for favoriteLocation in favoriteLocations{
            if favoriteLocation.placemark.coordinate.latitude == mapItem.placemark.coordinate.latitude && favoriteLocation.placemark.coordinate.longitude == mapItem.placemark.coordinate.longitude{return true}
        }
        
        return false
    }
    
    func removeMapItemFromFavoriteList(){
        for (index, favoriteLocation) in favoriteLocations.enumerated(){
            if favoriteLocation.placemark.coordinate.latitude == mapItem.placemark.coordinate.latitude && favoriteLocation.placemark.coordinate.longitude == mapItem.placemark.coordinate.longitude{
                favoriteLocations.remove(at: index)
                saveFavoriteLocationsList()
                return
            }
        }
    }
    
    func loadFavoriteLocationsList(){
        
        guard let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
        let favoriteLocationsPath = documentsDir.appendingPathComponent("favoriteLocationsPath").path
        guard FileManager.default.fileExists(atPath: favoriteLocationsPath) else {return}
        favoriteLocations = NSKeyedUnarchiver.unarchiveObject(withFile: favoriteLocationsPath) as! [FavoriteLocation]
        
        
    }
    
    func reportIssue(){
        
        guard UserDefaults.standard.bool(forKey: DefaultKeys.signedIn) else {
            let signUpViewController = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
            signUpViewController.originalPresenter = self
            present(signUpViewController, animated: true, completion: nil)
            return
        }
        
        let reportLocationIssueNavigationController = storyboard?.instantiateViewController(withIdentifier: "reportLocationIssueNavigationController") as! UINavigationController
        let reportLocationIssueViewController = reportLocationIssueNavigationController.topViewController as! ReportLocationIssueTableViewController
        reportLocationIssueViewController.delegate = self
        present(reportLocationIssueNavigationController, animated: true, completion: nil)
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.backgroundColor = UIColor.clear
        if indexPath.row == 3 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: self.view.bounds.width, bottom: 0, right: 0)
        } else if indexPath.row == 2 {
            if doesMapItemExistInFavoriteLocationsList(){
                cell.accessoryType = .checkmark
            } else {
                cell.accessoryType = .none
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.row == 2 {
            reportIssue()
            return indexPath
        }else {
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func saveFavoriteLocationsList(){
        
        guard let documentsDir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
        let favoriteLocationsPath = documentsDir.appendingPathComponent(KeyedArchiverKeys.favoriteLocationsListKey).path
        if NSKeyedArchiver.archiveRootObject(favoriteLocations, toFile: favoriteLocationsPath){
        } else {
            print("failed favorited list successfully!")
        }
        
    }
    
    
    @IBAction func unwindToAddressTableViewController(_ sender: UIStoryboardSegue){
        
        let reportLocationIssueViewController = storyboard?.instantiateViewController(withIdentifier: "reportLocationIssueViewController") as! ReportLocationIssueTableViewController
        reportLocationIssueViewController.delegate = self
        present(reportLocationIssueViewController, animated: true, completion: nil)
        
    }
}

extension PinnedAddressTableViewController: ReportLocationIssueTableViewControllerDelegate{
    func reportLocationIssueTableViewControllerDidTapCancelButton(_ reportLocationIssueTableViewController: ReportLocationIssueTableViewController) {
        dismiss(animated: true, completion: nil)
    }
}
