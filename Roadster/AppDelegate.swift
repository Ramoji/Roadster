
//
//  AppDelegate.swift
//  Roadster
//
//  Created by A Ja on 9/6/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

import UIKit
import CoreData
import Foundation
import CoreLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let states = States()
    let locationManager = CLLocationManager()
    lazy var managedObjectContext: NSManagedObjectContext = {
        //**********************Getting Data Model********************************
        guard let dataModelURL = Bundle.main.url(forResource: "USRestStop", withExtension: "mom") else {
            fatalError("Failed to get the damn URL again!")
        }
        guard let dataModel = NSManagedObjectModel(contentsOf: dataModelURL) else {
            fatalError("Failed to initiate data model from the main bundle!")
        }
        //**********************Getting persistence store*************************
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dataStoreURL = documentsDirectoryURL.appendingPathComponent("datastore.sqlite")
        print(dataStoreURL.path)
        if !FileManager.default.fileExists(atPath: dataStoreURL.path){
            let sourceSqliteURLs = [Bundle.main.url(forResource: "datastore", withExtension: "sqlite"), Bundle.main.url(forResource: "datastore", withExtension: "sqlite-shm"), Bundle.main.url(forResource: "datastore", withExtension: "sqlite-wal")]
            let destSqliteURLs = [documentsDirectoryURL.appendingPathComponent("datastore.sqlite"), documentsDirectoryURL.appendingPathComponent("datastore.sqlite-shm"), documentsDirectoryURL.appendingPathComponent("datastore.sqlite-wal")]
            for (index, sourceURL) in sourceSqliteURLs.enumerated() {
                do{ try FileManager.default.copyItem(at: sourceURL!, to: destSqliteURLs[index])
                }catch let error as NSError{
                    print(error.debugDescription)
                    print(error.userInfo)
                    fatalError("Error while copying data store files from main bundle to the documents directory!")
                }
            }
        }
        do{
            let persistenceCordinator = NSPersistentStoreCoordinator(managedObjectModel: dataModel)
            try persistenceCordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dataStoreURL, options: nil)
        //*******************Initiating managed object context**********************
            let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            context.persistentStoreCoordinator = persistenceCordinator
            return context
        }catch let error as NSError{
            print(error.debugDescription)
            fatalError("Error initiating managed object context!")
        }
    }()
    
    lazy var userSavedStopsManagedObjectContext: NSManagedObjectContext = {
        guard let dataModelURL = Bundle.main.url(forResource: "UserSavedStops", withExtension: "momd") else {
            fatalError("*** Failed to get UserSavedStops data model URL from the main bundle!")
        }
        
        guard let dataModel = NSManagedObjectModel(contentsOf: dataModelURL) else {
            fatalError("*** Failed to initiate data model from data model URL.")
        }
        
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dataStoreURL = documentsDirectory.appendingPathComponent("UserSavedStops.sqlite")
        
        do{
            let persistentStoreCoordinator: NSPersistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: dataModel)
            try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: dataStoreURL, options: nil)
            let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
            context.persistentStoreCoordinator = persistentStoreCoordinator
            return context
        } catch {
            fatalError("*** Failed to initiate managed object context for UserSavedStops!")
        }
        
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool{
        
        let tabBarController = window?.rootViewController as! UITabBarController
        let controllers = tabBarController.viewControllers
        let navigationController = controllers![0] as! UINavigationController
        let stateListViewController = navigationController.topViewController as! StateListViewController
        stateListViewController.managedObjectContext = managedObjectContext
        stateListViewController.appWindow = window
        let navigationController2 = controllers![1] as! UINavigationController
        let nearByViewController = navigationController2.topViewController as! NearByViewController
        POIProvider.managedObjectContext = managedObjectContext
        CoreDataHelper.shared.userSavedStopsManagedObjectContext = userSavedStopsManagedObjectContext
        CoreDataHelper.shared.restStopDatabaseManagedObjectContext = managedObjectContext
        
        if CLLocationManager.authorizationStatus() == .notDetermined{
            locationManager.requestWhenInUseAuthorization()
        }
        nearByViewController.managedObjectContext = managedObjectContext

        window?.tintColor = UIColor(red: 67/255, green: 129/255, blue: 244/255, alpha: 1)
        
        //*******DANGER********
        //renameHighway(in: "WA", oldHighwayName: "SR-12", newHighwayName: "US-12")
        //deleteRow(in: "OR", on: "SR-401")
        //*********************
        
       return true
    }
    

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func defineUserDefaults(){
        UserDefaults.standard.register(defaults: ["firstTimeRun": true])
    }
    
    func deleteRow(in state: String, on highway: String){
        
        var restStops: [USRestStop] = []
        let fetchRequest: NSFetchRequest<USRestStop> = NSFetchRequest()
        fetchRequest.entity = USRestStop.entity()
        
        let statePredicate = NSPredicate(format: "state==%@", state)
        let highwayPredicate = NSPredicate(format: "routeName==%@", highway)
        
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [statePredicate, highwayPredicate])
        
        fetchRequest.predicate = compoundPredicate
        
        do{
            let managedObjects = try managedObjectContext.fetch(fetchRequest)
            for managedObject in managedObjects{
                restStops.append(managedObject)
            }
        }catch{
            fatalError("*** Failed to fetch to delete rest stops!")
        }
        
        for restStop in restStops{
            do{
                managedObjectContext.delete(restStop)
                try managedObjectContext.save()
                
            } catch {
                fatalError("*** failed to delete selected rest stop!")
            }
            
        }
        
        
    }
    
    func renameHighway(in state: String, oldHighwayName: String, newHighwayName: String){
        var restStops: [USRestStop] = []
        let fetchRequest: NSFetchRequest<USRestStop> = NSFetchRequest()
        fetchRequest.entity = USRestStop.entity()
        
        let statePredicate = NSPredicate(format: "state==%@", state)
        let highwayPredicate = NSPredicate(format: "routeName==%@", oldHighwayName)
        
        let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [statePredicate, highwayPredicate])
        
        fetchRequest.predicate = compoundPredicate
        
        do{
            let managedObjects = try managedObjectContext.fetch(fetchRequest)
            for managedObject in managedObjects{
                restStops.append(managedObject)
            }
        }catch let error as NSError{
            print(error.debugDescription)
            fatalError("*** Failed to fetch restStops in order to rename highway name!")
        }
        
        for restStop in restStops{
            
            restStop.routeName = newHighwayName
            do{
                try managedObjectContext.save()
                print("*** Saved rest stop name change!")
            }catch let error as NSError{
                print(error.debugDescription)
                fatalError("*** Failed to save new name for rest stop!")
            }
        }
    }

}

