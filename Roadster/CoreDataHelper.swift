//
//  CoreDataHelper.swift
//  Roadster
//
//  Created by EA JA on 6/16/17.
//  Copyright © 2017 A Ja. All rights reserved.
//

import Foundation
import CoreData

class CoreDataHelper{
    static let shared = CoreDataHelper()
    
    var userSavedStopsManagedObjectContext: NSManagedObjectContext!
    
    func saveFavorite(restStop: USRestStop){
        let favorite = Favorite(context: userSavedStopsManagedObjectContext)
        favorite.loadFavoriteStop(restStop: restStop)
        userSavedStopsManagedObjectContext.insert(favorite)
        do{
            try userSavedStopsManagedObjectContext.save()
        }catch let error as NSError{
            print(error.debugDescription)
            fatalError("*** Failed to save a favorite rest stop to core data!")
        }
    }
    
    func saveFrequent(restStop: USRestStop){
        let frequent = Frequent(context: userSavedStopsManagedObjectContext)
        frequent.loadFrequentStop(restStop: restStop)
        userSavedStopsManagedObjectContext.insert(frequent)
        do{
            try userSavedStopsManagedObjectContext.save()
        }catch let error as NSError{
            print(error.debugDescription)
            fatalError("*** Failed to save a frequent rest stop to core data!")
        }
    }
    
    func deleteFavorite(restStop: USRestStop){
        var managedObjects: [NSManagedObject] = []
        let fetchRequest: NSFetchRequest<Favorite> = NSFetchRequest()
        fetchRequest.entity = Favorite.entity()
        let latPredicate = NSPredicate(format: "latitude = %f", restStop.latitude)
        
        let longPredicate = NSPredicate(format: "longitude = %f", restStop.longitude)
        let andCompoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [latPredicate,longPredicate])
        fetchRequest.predicate = andCompoundPredicate
        do{
            managedObjects = try userSavedStopsManagedObjectContext.fetch(fetchRequest)
            for managedObject in managedObjects{
                userSavedStopsManagedObjectContext.delete(managedObject)
            }
            try userSavedStopsManagedObjectContext.save()
        } catch {
            fatalError("*** Encountered error while trying to delete a Favorite object.")
        }
    }
    
    func deleteFrequent(latitude: Double, longitude: Double){
        var managedObjects: [NSManagedObject] = []
        let fetchRequest: NSFetchRequest<Frequent> = NSFetchRequest()
        fetchRequest.entity = Frequent.entity()
        let latPredicate = NSPredicate(format: "latitude=%f", latitude)
        let longPredicate = NSPredicate(format: "longitude=%f", longitude)
        let andCompoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [latPredicate,longPredicate])
        fetchRequest.predicate = andCompoundPredicate
        do{
            managedObjects = try userSavedStopsManagedObjectContext.fetch(fetchRequest)
            for managedObject in managedObjects{
                userSavedStopsManagedObjectContext.delete(managedObject)
            }
            try userSavedStopsManagedObjectContext.save()
        } catch {
            fatalError("*** Encountered error while trying to delete a Frequent object.")
        }
    }
    
    func getFavorites() -> [Favorite]{
        var managedObjects: [Favorite] = []
        let fetchRequest: NSFetchRequest<Favorite> = NSFetchRequest()
        fetchRequest.entity = Favorite.entity()
        do{
            managedObjects = try userSavedStopsManagedObjectContext.fetch(fetchRequest)
        } catch {
            fatalError("*** Failed to fetch favorites.")
        }
        return managedObjects
    }
    
    func getFrequents() -> [Frequent]{
        var managedObjects: [Frequent] = []
        let fetchRequest: NSFetchRequest<Frequent> = NSFetchRequest()
        fetchRequest.entity = Frequent.entity()
        do{
            managedObjects = try userSavedStopsManagedObjectContext.fetch(fetchRequest)
        } catch {
            fatalError("*** Failed to fetch favorites.")
        }
        return managedObjects
    }
}
