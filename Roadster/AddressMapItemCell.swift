
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit
import MapKit

class AddressMapItemCell: UITableViewCell {
    
    @IBOutlet weak var addressImageView: UIImageView!
    @IBOutlet weak var streetAddressLabel: UILabel!
    @IBOutlet weak var cityStateAddressLabel: UILabel!

    override func awakeFromNib() {
        
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        
        super.setSelected(selected, animated: animated)
        
    }

    //Configure address cell using the provided map item
    
    func configureCell(for mapItem: MKMapItem){
        
        prepLabels()
        
        self.backgroundColor = UIColor.clear
        
        addressImageView.image = #imageLiteral(resourceName: "yelpLocation").resizeImage(CGSize(width: 40.0, height: 40.0)).withRenderingMode(.alwaysOriginal)
        
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
        
    }
    
    //This mothod is called before the cell is configured to rest all text within the cell
    
    func prepLabels(){
        
        addressImageView.image = nil
        
        streetAddressLabel.text = ""
        
        cityStateAddressLabel.text = ""
        
    }
    
}
