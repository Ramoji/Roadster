//
//  HistoryAddressCellTableViewCell.swift
//  Roadster
//
//  Created by EA JA on 12/8/17.
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit
import Foundation
import MapKit

class HistoryAddressCell: UITableViewCell {

    
    @IBOutlet weak var streetAddressLabel: UILabel!
    @IBOutlet weak var cityStateAddressLabel: UILabel!
    @IBOutlet weak var userDefinedAddressNameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
    
    }
    
    func configureCell(for favoriteLocation: FavoriteLocation , and currentUserLocation: CLLocation?){
        
        prepLabels()
        
        let mapItem = MKMapItem(placemark: favoriteLocation.placemark)
        
        if let currentUserLocation = currentUserLocation{
            
            distanceLabel.isHidden = false
            
            let addressLocation = CLLocation(latitude: mapItem.placemark.coordinate.latitude, longitude: mapItem.placemark.coordinate.longitude)
            
            let distanceFromUser = (round((currentUserLocation.distance(from: addressLocation) / 1609) * 10)) / 10
            
            if distanceFromUser == 0 {
                
                distanceLabel.text = "Near by"
                
            }else if distanceFromUser < 1 {
                
                distanceLabel.text = "\(distanceFromUser) mi"
                
            } else {
                
                distanceLabel.text = "\(Int(distanceFromUser)) mi"
            }
            
        } else {
            
            distanceLabel.isHidden = true
            
        }
        
        self.backgroundColor = UIColor.clear
        
        let placemark = mapItem.placemark
        
        var streetAddress = ""
        
        var cityStateCountry = ""
        
        if let subThoroughfare = placemark.subThoroughfare{
            
            streetAddress = subThoroughfare
            
        }
        
        if let thoroughfare = placemark.thoroughfare{
            
            streetAddress += " " + thoroughfare
            
        }
        
        if let city = placemark.locality{
            
            cityStateCountry = city
            
        }
        
        if let state = placemark.administrativeArea{
            
            cityStateCountry += ", " + state
            
        }
        
        if let country = placemark.country{
            
            cityStateCountry += ", " + country
            
        }
        
        streetAddressLabel.text = streetAddress
        
        cityStateAddressLabel.text = cityStateCountry
        
        if let locationName = favoriteLocation.locationName{
            
            userDefinedAddressNameLabel.text = locationName.capitalized
            
        }
        
    }
    
    func prepLabels(){

        streetAddressLabel.text = ""
        
        cityStateAddressLabel.text = ""
        
    }

}
