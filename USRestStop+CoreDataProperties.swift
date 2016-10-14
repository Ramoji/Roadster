//
//  USRestStop+CoreDataProperties.swift
//  Roadster
//
//  Created by A Ja on 10/7/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

import Foundation
import CoreData


extension USRestStop {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<USRestStop> {
        return NSFetchRequest<USRestStop>(entityName: "USRestStop");
    }

    @NSManaged public var bound: String
    @NSManaged public var closed: Bool
    @NSManaged public var drinkingWater: Bool
    @NSManaged public var foodRest: Bool
    @NSManaged public var gas: Bool
    @NSManaged public var handicappedFacilities: Bool
    @NSManaged public var index: Int32
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var noFacilities: Bool
    @NSManaged public var noTrucks: Bool
    @NSManaged public var petArea: Bool
    @NSManaged public var phone: Bool
    @NSManaged public var picnicTables: Bool
    @NSManaged public var restRoom: Bool
    @NSManaged public var routeName: String
    @NSManaged public var rvDump: Bool
    @NSManaged public var scenic: Bool
    @NSManaged public var state: String
    @NSManaged public var stopDescription: String
    @NSManaged public var stopName: String
    @NSManaged public var vMachine: Bool

}
