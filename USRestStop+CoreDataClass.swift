//
//  USRestStop+CoreDataClass.swift
//  Roadster
//
//  Created by A Ja on 10/7/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

import Foundation
import CoreData
import MapKit


public class USRestStop: NSManagedObject, MKAnnotation{
    public var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    public var title: String?
    public var subtitle: String?
    override init(entity: NSEntityDescription, insertInto: NSManagedObjectContext?){
        super.init(entity: entity, insertInto: insertInto)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        title = stopDescription.capitalized
        subtitle = stopName
    }
    
}
