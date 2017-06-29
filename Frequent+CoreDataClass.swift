//
//  Frequent+CoreDataClass.swift
//  
//
//  Created by EA JA on 6/16/17.
//
//

import Foundation
import CoreData

@objc(Frequent)
public class Frequent: NSManagedObject {

    func loadFrequentStop(restStop: USRestStop){
        
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
        
    }
}
