
//  Copyright © 2017 A Ja. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation
import YelpAPI

class HistoryYelpBusiness: NSObject, NSCoding, MKAnnotation{
    var businessIdentifier: String
    var name: String
    var rating: Double
    var reviewCount: UInt
    var category: String
    var businessAddress: String
    var latitude: Double?
    var longitude: Double?
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    
    init(business: YLPBusiness) {
        businessIdentifier = business.identifier
        name = business.name
        rating = business.rating
        reviewCount = business.reviewCount
        
        if !business.categories.isEmpty{
            category = business.categories[0].name
        } else {
            category = ""
        }
        if !business.location.address.isEmpty{
            businessAddress = business.location.address[0]
        } else {
            businessAddress = ""
        }
        
        latitude = business.location.coordinate?.latitude
        longitude = business.location.coordinate?.longitude
        
        if let _ = latitude{
            coordinate = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
        }
    }
    
    init(businessIdentifier: String, name: String, rating: Double, reviewCount: UInt, category: String, businessAddress: String, latitude: Double?, longitude: Double?) {
        self.businessIdentifier = businessIdentifier
        self.name = name
        self.rating = rating
        self.reviewCount = reviewCount
        self.category = category
        self.businessAddress = businessAddress
        self.latitude = latitude
        self.longitude = longitude
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        businessIdentifier = aDecoder.decodeObject(forKey: "businessIdentifier") as! String
        name = aDecoder.decodeObject(forKey: "name") as! String
        rating = aDecoder.decodeDouble(forKey: "rating")
        reviewCount = aDecoder.decodeObject(forKey: "reviewCount") as! UInt
        category = aDecoder.decodeObject(forKey: "category") as! String
        businessAddress = aDecoder.decodeObject(forKey: "businessAddress") as! String
        latitude = aDecoder.decodeObject(forKey: "latitude") as! Double?
        longitude = aDecoder.decodeObject(forKey: "longitude") as! Double?
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(businessIdentifier, forKey: "businessIdentifier")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(rating, forKey: "rating")
        aCoder.encode(reviewCount, forKey: "reviewCount")
        aCoder.encode(category, forKey: "category")
        aCoder.encode(businessAddress, forKey: "businessAddress")
        aCoder.encode(latitude, forKey: "latitude")
        aCoder.encode(longitude, forKey: "longitude")
    }
}
