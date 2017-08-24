//
//  NearViewStaticDetailTableTableViewController.swift
//  Roadster
//
//  Created by EA JA on 8/14/17.
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit
import MapKit

struct segueIdentifiers{
    static let nearRestStopChildDetailTableViewControllerSegueIdentifier = "nearRestStopChildDetailTableViewControllerSegueIdentifier"
}

class NearRestStopChildDetailTableViewController: UITableViewController {
    
    var restStop: USRestStop!
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var parkingImageView: UIImageView!
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
    
    @IBOutlet weak var facilitiesLabel: UILabel!
    
    @IBOutlet weak var truck: UIImageView!
    @IBOutlet weak var sedanCar: UIImageView!
    @IBOutlet weak var trailer: UIImageView!
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var reportInfoButton: UIButton!
    @IBOutlet weak var navigateButton: UIButton!
    @IBOutlet weak var frequentButton: UIButton!
    
    var imageViews: [UIImageView]!

    override func viewDidLoad() {
        super.viewDidLoad()
        imageViews = [imageViewOne, imageViewTwo, imageViewThree, imageViewFour, imageViewFive, imageViewSix, imageViewSeven, imageViewEight, imageViewNine, imageViewTen]
        mapView.isScrollEnabled = false
        setUpViewForRestStop()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return super.numberOfSections(in: tableView)
        
        
    }
    
    override func loadView() {
        super.loadView()
        
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if section == 0 {
            return super.tableView(tableView, numberOfRowsInSection: section)
        } else {
            return 1
        }
    }
    
    func setUpViewForRestStop(){
        let iconSize = CGSize(width: 25.0, height: 25.0)
        let vehicleIconSize = CGSize(width: 25.0, height: 25.0)
        prepIconViews()
        if let restStop = restStop{
            mapView.addAnnotation(restStop)
            parkingImageView.image = UIImage(named: "parking")?.resizeImage(iconSize)
            sedanCar.image = UIImage(named: "sedan")?.resizeImage(iconSize)
            if restStop.rvDump{
                trailer.image = UIImage(named: "rvDump")?.resizeImage(vehicleIconSize)
            }
            if restStop.trucks{
                truck.image = UIImage(named: "truck")?.resizeImage(vehicleIconSize)
            }
            parkingImageView.image = UIImage(named: "parking")?.resizeImage(iconSize)
        }
        setUpMapView()
        configureFacilityIcons()
        
        if restStop.favorite{
            favoriteButton.imageView?.contentMode = .scaleAspectFit
            favoriteButton.setTitle("", for: .normal)
            favoriteButton.setImage(UIImage(named: "favoriteOn")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            
            favoriteButton.imageView?.contentMode = .scaleAspectFit
            favoriteButton.setTitle("", for: .normal)
            favoriteButton.setImage(UIImage(named: "favoriteOff")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        reportInfoButton.imageView?.contentMode = .scaleAspectFit
        reportInfoButton.setTitle("", for: .normal)
        reportInfoButton.setImage(UIImage(named: "reportInfo")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: UIControlState.normal)
        
        navigateButton.imageView?.contentMode = .scaleAspectFit
        navigateButton.setTitle("", for: .normal)
        navigateButton.setImage(UIImage(named: "navigate")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: UIControlState.normal)
        
        if restStop.frequent{
            frequentButton.imageView?.contentMode = .scaleAspectFit
            frequentButton.setTitle("", for: .normal)
            frequentButton.setImage(UIImage(named: "frequentOn")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            frequentButton.imageView?.contentMode = .scaleAspectFit
            frequentButton.setTitle("", for: .normal)
            frequentButton.setImage(UIImage(named: "frequentOff")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        view.setNeedsLayout()
        
    }
    
    private func prepIconViews(){
        for imageView in imageViews{
            imageView.isHidden = true
            imageView.image = nil
        }
    }
    
    func setUpMapView(){
        if let restStop = restStop{
            let region = MKCoordinateRegionMakeWithDistance(restStop.coordinate, 500, 500)
            mapView.setRegion(region, animated: true)
            mapView.isUserInteractionEnabled = false
        }
    }
    
    private func configureFacilityIcons(){
        let facilites = POIProvider.getFacilityList(forRestStop: restStop)
        for (index, facility) in facilites.enumerated(){
            let imageSize = CGSize(width: 20.0, height: 20.0)
            let facilityImageView = imageViews![index]
            facilityImageView.isHidden = false
            facilityImageView.image = UIImage(named: facility)?.resizeImage(imageSize)
        }
    }


    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    @IBAction func saveFrequent(_ sender: UIButton){
        let managedObjectContext = restStop.managedObjectContext!
        if restStop.frequent{
            //change rest stop frequent status and re-save (unfrequent)
            frequentButton.setImage(UIImage(named: "frequentOff")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: .normal)
            restStop.frequent = false
            do {
                try managedObjectContext.save()
                print("*** Deleted frequent!")
            } catch {
                fatalError("*** Failed to update rest stop frequent status.")
            }
            //remove favorite from core data
            CoreDataHelper.shared.deleteFrequent(latitude: restStop.latitude, longitude: restStop.longitude)
        } else {
            //change rest stop frequent status and re-save (frequent)
            frequentButton.setImage(UIImage(named: "frequentOn")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: .normal)
            restStop.frequent = true
            do {
                try managedObjectContext.save()
                print("*** Saved frequent!")
            } catch {
                fatalError("*** Failed to update rest stop frequent status.")
            }
            //save favorite to core data
            CoreDataHelper.shared.saveFrequent(restStop: restStop)
        }
    }
    
    @IBAction func saveFavorite(_ sender: UIButton){
        let managedObjectContext = restStop.managedObjectContext!
        if restStop.favorite{
            //change rest stop favotire status and re-save (unfavorite)
            favoriteButton.setImage(UIImage(named: "favoriteOff")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: .normal)
            restStop.favorite = false
            do{
                try managedObjectContext.save()
                print("*** Deleted favorite!")
            }catch{
                fatalError("*** Failed to update rest stop favorite status.")
            }
            //remove favorite from core data
            print("*** latitude: \(restStop.latitude), longitude: \(restStop.longitude)")
            CoreDataHelper.shared.deleteFavorite(restStop: restStop)
        } else {
            //change rest stop favotire status and re-save (favorite)
            favoriteButton.setImage(UIImage(named: "favoriteOn")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: .normal)
            restStop.favorite = true
            do{
                try managedObjectContext.save()
                print("*** Saved favorite!")
            }catch{
                fatalError("*** Failed to update rest stop favorite status.")
            }
            //save favorite to core data
            CoreDataHelper.shared.saveFavorite(restStop: restStop)
        }
    }
    
    @IBAction func navigate(){
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(restStop.latitude, restStop.longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Start"
        mapItem.openInMaps(launchOptions: options)
        
    }

}

extension NearRestStopChildDetailTableViewController: NearStaticRestStopDetailViewControllerDelegate{
    func nearStaticRestStopDetailViewControllerDidTapCloseButton(_ nearStaticRestStopDetailViewController: NearStaticRestStopDetailViewController) {
        
    }
    
    func nearStaticRestStopDetailViewControllerDidRequestUpdate(_ narStaticRestStopDetailViewControllerwith: NearStaticRestStopDetailViewController, restStop: USRestStop) {
        
    }
}
