//
//  PinRestStopAnnotation.swift
//  Roadster
//
//  Created by A Ja on 11/25/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class PinRestStopAnnotation: NSObject, MKAnnotation{
    public var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    init(pinCoordinate: CLLocationCoordinate2D){
        coordinate = CLLocationCoordinate2D(latitude: pinCoordinate.latitude, longitude: pinCoordinate.longitude)
    }
}
