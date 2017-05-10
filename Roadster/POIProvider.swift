//
//  POIProvider.swift
//  Roadster
//
//  Created by EA JA on 5/9/17.
//  Copyright © 2017 A Ja. All rights reserved.
//

import Foundation

import Foundation
import CoreData

struct PossibleDirections {
    static let eastBound = "EB"
    static let westBound = "WB"
    static let northBound = "NB"
    static let southBound = "SB"
    static let eastWestRoute = "EASTWEST"
    static let northSouthRoute = "NORTHSOUTH"
}

class POIProvider{
    
    static var managedObjectContext: NSManagedObjectContext?
    
    class func getRestStops(inState state: String) -> [USRestStop]{
        
        var restStops:[USRestStop]?
        
        let request: NSFetchRequest<USRestStop> = NSFetchRequest()
        request.entity = USRestStop.entity()
        
        let predicate = NSPredicate(format: "state==%@", state)
        
        request.predicate = predicate
        
        do {
            restStops = try managedObjectContext!.fetch(request)
        } catch let error as NSError{
            print("*** \(error.debugDescription)")
            print("*** \(error.userInfo)")
        }
        
        if let restStops = restStops{
            return restStops
        } else {return []}
    }
    
    class func getUniqueRouteNames(inState state: String) -> [String]{
        let restStops = getRestStops(inState: state)
        var routeNames: [String] = []
        for stop in restStops{
            if stop.routeName != "ADDRESS"{
                routeNames.append(stop.routeName)
            }
        }
        
        return routeNames.unique.sorted{ lhs, rhs in
            return lhs.localizedStandardCompare(rhs) == ComparisonResult.orderedAscending
        }
    }
    
    class func getRestStops(inState state: String, onRoute routeName: String) -> [USRestStop]{
        var restStops:[USRestStop]?
        
        let request: NSFetchRequest<USRestStop> = NSFetchRequest()
        request.entity = USRestStop.entity()
        
        let statePredicate = NSPredicate(format: "state==%@", state)
        let routeNamePredicate = NSPredicate(format: "routeName==%@", routeName)
        
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [statePredicate, routeNamePredicate])
        
        request.predicate = compoundPredicate
        
        do {
            restStops = try managedObjectContext!.fetch(request)
        } catch let error as NSError{
            print("*** \(error.debugDescription)")
            print("*** \(error.userInfo)")
        }
        
        if let restStops = restStops {
            return restStops
        } else {
            return []
        }
    }
    
    
    // for this method, the returning value can have two possible values. EW represents routes that go east to west and vice
    //versa, and NS represents routes that go north to south and vice versa.
    class func getRouteClassification(inState state: String ,onRoute routeName: String) -> String {
        
        var direction: String?
        
        let restStops: [USRestStop] = getRestStops(inState: state, onRoute: routeName)
        var eastBoundRestStops: [USRestStop] = []
        var westBoundRestStops: [USRestStop] = []
        var northBoundRestStops: [USRestStop] = []
        var southBoundRestStops: [USRestStop] = []
        
        for restStop in restStops {
            
            if restStop.direction.contains(PossibleDirections.eastBound){
                eastBoundRestStops.append(restStop)
            } else if restStop.direction.contains(PossibleDirections.westBound){
                westBoundRestStops.append(restStop)
            } else if restStop.direction.contains(PossibleDirections.northBound){
                northBoundRestStops.append(restStop)
            } else if restStop.direction.contains(PossibleDirections.southBound){
                southBoundRestStops.append(restStop)
            }
        }
        
        if eastBoundRestStops.count != 0 && westBoundRestStops.count != 0 {
            direction = PossibleDirections.eastWestRoute
        } else if northBoundRestStops.count != 0 && southBoundRestStops.count != 0{
            direction = PossibleDirections.northSouthRoute
        }
        
        return direction!
    }
    
    
    class func getRestStops(inState state: String, onRoute routeName: String, forDirection direction: String) -> [USRestStop]{
        
        var restStops: [USRestStop] = []
        
        let request: NSFetchRequest<USRestStop> = NSFetchRequest()
        request.entity = USRestStop.entity()
        let statePredicate = NSPredicate(format: "state==%@", state)
        let routePredicate = NSPredicate(format: "routeName==%@", routeName)
        
        
        request.predicate = NSCompoundPredicate(type: .and, subpredicates: [statePredicate, routePredicate])
        
        do{
            let managedObjects = (try managedObjectContext?.fetch(request))!
            for managedObject in managedObjects {
                if managedObject.direction.contains(direction){
                    restStops.append(managedObject)
                }
            }
        }catch let error as NSError{
            print(error.debugDescription)
            print(error.userInfo)
        }
        
        switch direction {
        case "NB":
            restStops = restStops.sorted(by: { lhs, rhs in
                return lhs.latitude < rhs.latitude
            })
        case "SB":
            restStops = restStops.sorted(by: { lhs, rhs in
                return lhs.latitude > rhs.latitude
            })
        case "EB":
            restStops = restStops.sorted(by: { lhs, rhs in
                return lhs.longitude < rhs.longitude
            })
        case "WB":
            restStops = restStops.sorted(by: { lhs, rhs in
                return lhs.longitude > rhs.longitude
            })
            
        default:
            print("Failed to sort list of rest stops based on latitude / longitude in getRestStops(inState:onRoute:forDirection in POIProvider)")
        }
        
        return restStops
    }
}



extension Array where Element: Equatable{
    var unique: [Element] {
        var uniqueValues: [Element] = []
        forEach{element in
            if !uniqueValues.contains(element){
                uniqueValues += [element]
            }
        }
        return uniqueValues
    }
}

