//
//  Favorite+CoreDataClass.swift
//  
//
//  Created by EA JA on 6/16/17.
//
//

import Foundation
import CoreData
import CoreLocation
import MapKit

@objc(Favorite)
public class Favorite: NSManagedObject, MKAnnotation {
    
    public var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    override public init(entity: NSEntityDescription, insertInto context: NSManagedObjectContext?) {
        super.init(entity: entity, insertInto: context)
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func loadFavoriteStop(restStop: USRestStop){
        
        self.closed = restStop.closed
        self.direction = restStop.direction
        self.disabledFacilities = restStop.disabledFacilities
        self.facilities = restStop.facilities
        self.favorite = restStop.favorite
        self.frequent = restStop.frequent
        self.gas = restStop.gas
        self.latitude = restStop.latitude
        self.longitude = restStop.longitude
        self.mileMaker = restStop.mileMarker
        self.petArea = restStop.petArea
        self.phone = restStop.phone
        self.restaurant = restStop.restaurant
        self.restroom = restStop.restroom
        self.routeName = restStop.routeName
        self.rvDump = restStop.rvDump
        self.scenic = restStop.scenic
        self.state = restStop.state
        self.stopDescription = restStop.stopDescription
        self.tables = restStop.tables
        self.trucks = restStop.trucks
        self.vendingMachine = restStop.vendingMachine
        self.water = restStop.water
        self.coordinate = CLLocationCoordinate2D(latitude: restStop.latitude, longitude: restStop.longitude)
    }
}


