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
        guard let dataModelURL = Bundle.main.url(forResource: "DataModel", withExtension: "mom") else {
            fatalError("Failed to get the damn URL again!")
        }
        guard let dataModel = NSManagedObjectModel(contentsOf: dataModelURL) else {
            fatalError("Failed to initiate data model from the main bundle!")
        }
        //**********************Getting persistence store*************************
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let dataStoreURL = documentsDirectoryURL.appendingPathComponent("DataStore.sqlite")
        if !FileManager.default.fileExists(atPath: dataStoreURL.path){
            let sourceSqliteURLs = [Bundle.main.url(forResource: "DataStore", withExtension: "sqlite"), Bundle.main.url(forResource: "DataStore", withExtension: "sqlite-shm"), Bundle.main.url(forResource: "DataStore", withExtension: "sqlite-wal")]
            let destSqliteURLs = [documentsDirectoryURL.appendingPathComponent("DataStore.sqlite"), documentsDirectoryURL.appendingPathComponent("DataStore.sqlite-shm"), documentsDirectoryURL.appendingPathComponent("DataStore.sqlite-wal")]
            for (index, sourceURL) in sourceSqliteURLs.enumerated() {
                do{ try FileManager.default.copyItem(at: sourceURL!, to: destSqliteURLs[index])
                }catch{
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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool{

        let tabBarController = window?.rootViewController as! UITabBarController
        let controllers = tabBarController.viewControllers
        let navigationController = controllers![0] as! UINavigationController
        let stateListViewController = navigationController.topViewController as! StateListViewController
        stateListViewController.managedObjectContext = managedObjectContext
        stateListViewController.appWindow = window
        let navigationController2 = controllers![1] as! UINavigationController
        let nearByViewController = navigationController2.topViewController as! NearByViewController
        nearByViewController.locationManger = self.locationManager
        nearByViewController.appWindow = window
        
        
        if CLLocationManager.authorizationStatus() == .notDetermined{
            locationManager.requestWhenInUseAuthorization()
        }
        nearByViewController.managedObjectContext = managedObjectContext
        let navigationController3 = controllers![2] as! UINavigationController
        let pinViewController = navigationController3.topViewController as! PinViewController
        pinViewController.managedObjectContext = managedObjectContext
        window?.tintColor = UIColor(red: 67/255, green: 129/255, blue: 244/255, alpha: 1)
        //**********DANGER ZONE PROCEED WITH CAUTION***********
        //editDatabase()
        //*****************************************************
        
        
       return true
    }
    
    func editDatabase(){
        let entityDescription = NSEntityDescription.entity(forEntityName: "USRestStop", in: managedObjectContext)
        let request = NSFetchRequest<USRestStop>(entityName: "USRestStop")
        let predicate1 = NSPredicate(format: "state == %@", "KY")
        let predicate2 = NSPredicate(format: "routeName == %@", "I-24")
        let predicate3 = NSPredicate(format: "bound == %@", "SB")
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate1, predicate2, predicate3])
        request.entity = entityDescription
        request.predicate = compoundPredicate
        
        do{
            let managedObjects = try managedObjectContext.fetch(request)
            for object in managedObjects{
                print("*** the objects found have the following route name: \(object.routeName)")
                print("*** the bounds for rest stops are: \(object.bound)")
            }
            
            correctBound(managedObjects)
            
        } catch let error as NSError {
            print(error.userInfo)
            print(error.debugDescription)
            fatalError("Failed to fetch managedObjects!")
        }
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
    
    
    
    
    func correctBound(_ objects: [USRestStop]){
        
        for object in objects{
        
            let objectToInsert = USRestStop(context: managedObjectContext)
            objectToInsert.routeName = object.routeName
            objectToInsert.bound = "EB"
            objectToInsert.closed = object.closed
            objectToInsert.drinkingWater = object.drinkingWater
            objectToInsert.foodRest = object.foodRest
            objectToInsert.gas = object.gas
            objectToInsert.handicappedFacilities = object.handicappedFacilities
            objectToInsert.index = object.index
            objectToInsert.latitude = object.latitude
            objectToInsert.longitude = object.longitude
            objectToInsert.noFacilities = object.noFacilities
            objectToInsert.noTrucks = object.noTrucks
            objectToInsert.petArea = object.petArea
            objectToInsert.phone = object.phone
            objectToInsert.picnicTables = object.picnicTables
            objectToInsert.restRoom = object.restRoom
            objectToInsert.rvDump = object.rvDump
            objectToInsert.scenic = object.scenic
            objectToInsert.state = object.state
            objectToInsert.stopDescription = object.stopDescription
            objectToInsert.stopName = object.stopName
            objectToInsert.vMachine = object.vMachine
            
            managedObjectContext.insert(objectToInsert)
            do{
                try managedObjectContext.save()
            } catch let error as NSError{
                fatalError("failed to save CORRECTED BOUND to persistence store!")
            }
            
            managedObjectContext.delete(object)
            do{
                try managedObjectContext.save()
            }catch let error as NSError{
                fatalError("failed to delete object from persistence store! 1")
            }
        }
        
    }
    
    
    func deleteRestStop(_ restStops: [USRestStop]){
        
        for restStop in restStops{
            managedObjectContext.delete(restStop)
            do{
                try managedObjectContext.save()
            }catch let error as NSError{
                print(error.debugDescription)
                fatalError("Failed to delete rest stop from the database!")
            }
        }
    }
}

