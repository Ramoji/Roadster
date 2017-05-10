//
//  USRestStop+CoreDataClass.swift
//  
//
//  Created by EA JA on 5/9/17.
//
//

import Foundation
import CoreData
import MapKit

@objc(USRestStop)
public class USRestStop: NSManagedObject, MKAnnotation{
    
    public var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    override public init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

}
