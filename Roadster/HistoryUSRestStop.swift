//
//  HistoryUSRestStop.swift
//  Roadster
//
//  Created by EA JA on 8/3/17.
//  Copyright © 2017 A Ja. All rights reserved.
//

import Foundation
import YelpAPI
import MapKit
import CoreLocation
class HistoryUSRestStop:NSObject, NSCoding, MKAnnotation{
    
    var closed: Bool
    var direction: String
    var disabledFacilities: Bool
    var facilities: Bool
    var favorite: Bool
    var frequent: Bool
    var gas: Bool
    var latitude: Double
    var longitude: Double
    var mileMarker: String
    var petArea: Bool
    var phone: Bool
    var restaurant: Bool
    var restroom: Bool
    var routeName: String
    var rvDump: Bool
    var scenic: Bool
    var state: String
    var stopDescription: String
    var tables: Bool
    var trucks: Bool
    var vendingMachine: Bool
    var water: Bool
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
    
    init(restStop: USRestStop) {
        self.closed = restStop.closed
        self.direction = restStop.direction
        self.disabledFacilities = restStop.disabledFacilities
        self.facilities = restStop.facilities
        self.favorite = restStop.favorite
        self.frequent = restStop.frequent
        self.gas = restStop.gas
        self.latitude = restStop.latitude
        self.longitude = restStop.longitude
        self.mileMarker = restStop.mileMarker
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
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    required init?(coder aDecoder: NSCoder){
        self.closed = aDecoder.decodeBool(forKey: "closed")
        self.direction = aDecoder.decodeObject(forKey: "direction") as! String
        self.disabledFacilities = aDecoder.decodeBool(forKey: "disabledFacilities")
        self.facilities = aDecoder.decodeBool(forKey: "facilities")
        self.favorite = aDecoder.decodeBool(forKey: "favorite")
        self.frequent = aDecoder.decodeBool(forKey: "frequent")
        self.gas = aDecoder.decodeBool(forKey: "gas")
        self.latitude = aDecoder.decodeDouble(forKey: "latitude")
        self.longitude = aDecoder.decodeDouble(forKey: "longitude")
        self.mileMarker = aDecoder.decodeObject(forKey: "mileMarker") as! String
        self.petArea = aDecoder.decodeBool(forKey: "petArea")
        self.phone = aDecoder.decodeBool(forKey: "phone")
        self.restaurant = aDecoder.decodeBool(forKey: "restaurant")
        self.restroom = aDecoder.decodeBool(forKey: "restroom")
        self.routeName = aDecoder.decodeObject(forKey: "routeName") as! String
        self.rvDump = aDecoder.decodeBool(forKey: "rvDump")
        self.scenic = aDecoder.decodeBool(forKey: "scenic")
        self.state = aDecoder.decodeObject(forKey: "state") as! String
        self.stopDescription = aDecoder.decodeObject(forKey: "stopDescription") as! String
        self.tables = aDecoder.decodeBool(forKey: "tables")
        self.trucks = aDecoder.decodeBool(forKey: "trucks")
        self.vendingMachine = aDecoder.decodeBool(forKey: "vendingMachine")
        self.water = aDecoder.decodeBool(forKey: "water")
        self.coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    func encode(with aCoder: NSCoder){
        aCoder.encode(closed, forKey: "closed")
        aCoder.encode(direction, forKey: "direction")
        aCoder.encode(disabledFacilities, forKey: "disabledFacilities")
        aCoder.encode(facilities, forKey: "facilities")
        aCoder.encode(favorite, forKey: "favorite")
        aCoder.encode(frequent, forKey: "frequent")
        aCoder.encode(gas, forKey: "gas")
        aCoder.encode(latitude, forKey: "latitude")
        aCoder.encode(longitude, forKey: "longitude")
        aCoder.encode(mileMarker, forKey: "mileMarker")
        aCoder.encode(petArea, forKey: "petArea")
        aCoder.encode(phone, forKey: "phone")
        aCoder.encode(restaurant, forKey: "restaurant")
        aCoder.encode(restroom, forKey: "restroom")
        aCoder.encode(routeName, forKey: "routeName")
        aCoder.encode(rvDump, forKey: "rvDump")
        aCoder.encode(scenic, forKey: "scenic")
        aCoder.encode(state, forKey: "state")
        aCoder.encode(stopDescription, forKey: "stopDescription")
        aCoder.encode(tables, forKey: "tables")
        aCoder.encode(trucks, forKey: "trucks")
        aCoder.encode(vendingMachine, forKey: "vendingMachine")
        aCoder.encode(water, forKey: "water")
        

    }
    
    
}


