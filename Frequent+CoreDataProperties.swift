//
//  Frequent+CoreDataProperties.swift
//  
//
//  Created by EA JA on 6/16/17.
//
//

import Foundation
import CoreData


extension Frequent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Frequent> {
        return NSFetchRequest<Frequent>(entityName: "Frequent")
    }

    @NSManaged public var closed: Bool
    @NSManaged public var direction: String
    @NSManaged public var disabledFacilities: Bool
    @NSManaged public var facilities: Bool
    @NSManaged public var favorite: Bool
    @NSManaged public var frequent: Bool
    @NSManaged public var gas: Bool
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var mileMaker: String
    @NSManaged public var petArea: Bool
    @NSManaged public var phone: Bool
    @NSManaged public var restaurant: Bool
    @NSManaged public var restroom: Bool
    @NSManaged public var routeName: String
    @NSManaged public var rvDump: Bool
    @NSManaged public var scenic: Bool
    @NSManaged public var state: String
    @NSManaged public var stopDescription: String
    @NSManaged public var tables: Bool
    @NSManaged public var trucks: Bool
    @NSManaged public var vendingMachine: Bool
    @NSManaged public var water: Bool

}
