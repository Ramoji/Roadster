
//  Copyright © 2017 A Ja. All rights reserved.
//

import Foundation
import MapKit

class YelpBusinessAnnotation: NSObject, MKAnnotation{
    
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    var title: String?
    var businessID: String?
    
    init(coordinate: CLLocationCoordinate2D, title: String, businessID: String) {
        self.coordinate = coordinate
        self.title  = title
        self.businessID = businessID
    }
    
    
}


