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
    var restStopDatabaseManagedObjectContext: NSManagedObjectContext!
    
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
    
    func saveFavorite(favorite: Favorite){
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
    
    func saveFrequent(frequent: Frequent){
        userSavedStopsManagedObjectContext.insert(frequent)
        do{
            try userSavedStopsManagedObjectContext.save()
        }catch let error as NSError{
            print(error.debugDescription)
            fatalError("*** Failed to save a frequent rest stop to core data!")
        }
    }
    
    func deleteFavorite(latitude: Double, longitude: Double){
        var managedObjects: [NSManagedObject] = []
        let fetchRequest: NSFetchRequest<Favorite> = NSFetchRequest()
        
        fetchRequest.entity = Favorite.entity()
        
        do{
            managedObjects = try userSavedStopsManagedObjectContext.fetch(fetchRequest)
            
            for managedObject in managedObjects{
                
                let favorite = managedObject as! Favorite
                if favorite.latitude == latitude && favorite.longitude == longitude{
                    userSavedStopsManagedObjectContext.delete(managedObject)
                }
                
            }
            try userSavedStopsManagedObjectContext.save()
            
            
        
        } catch {
            fatalError("*** Encountered error while trying to delete a Favorite object.")
        }
        
        
        let updateFavoriteStatusFetchRequest: NSFetchRequest<USRestStop> = NSFetchRequest()
        updateFavoriteStatusFetchRequest.entity = USRestStop.entity()
        
        do{
            let managedObjects = try restStopDatabaseManagedObjectContext.fetch(updateFavoriteStatusFetchRequest)
            for managedObject in managedObjects{
                if managedObject.latitude == latitude && managedObject.longitude == longitude{
                    if managedObject.favorite {
                        managedObject.favorite = false
                    }
                }
            }
            
            try restStopDatabaseManagedObjectContext.save()
            
        }catch{
            fatalError("*** Failed to update favorite stop status!")
        }
        
    }
    
    func deleteFrequent(latitude: Double, longitude: Double){
        var managedObjects: [NSManagedObject] = []
        let fetchRequest: NSFetchRequest<Frequent> = NSFetchRequest()
        fetchRequest.entity = Frequent.entity()
        
        do{
            managedObjects = try userSavedStopsManagedObjectContext.fetch(fetchRequest)
            
            for managedObject in managedObjects{
                
                let frequent = managedObject as! Frequent
                if frequent.latitude == latitude && frequent.longitude == longitude{
                  userSavedStopsManagedObjectContext.delete(managedObject)
                }
                
            }
            try userSavedStopsManagedObjectContext.save()
        } catch {
            fatalError("*** Encountered error while trying to delete a Frequent object.")
        }
        
        let updateFavoriteStatusFetchRequest: NSFetchRequest<USRestStop> = NSFetchRequest()
        updateFavoriteStatusFetchRequest.entity = USRestStop.entity()
        
        do{
            let managedObjects = try restStopDatabaseManagedObjectContext.fetch(updateFavoriteStatusFetchRequest)
            for managedObject in managedObjects{
                if managedObject.latitude == latitude && managedObject.longitude == longitude{
                    if managedObject.frequent {
                        managedObject.frequent = false
                    }
                }
            }
            
            try restStopDatabaseManagedObjectContext.save()
            
        }catch{
            fatalError("*** Failed to update favorite stop status!")
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
