//
//  HighwayListViewController.swift
//  Roadster
//
//  Created by A Ja on 9/24/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

import UIKit
import CoreData

class HighwayListViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var managedObjectContext: NSManagedObjectContext!
    var state: String!
    var stateAbbreviation: String!
    var routes: [String] = [String]()
    let blurredBackgroundView = BlurredBackgroundView(frame: .zero, addBackgroundPic: true)
    var appWindow: UIWindow!
    var fullStateName: String!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerNibs()
        routes = POIProvider.getUniqueRouteNames(inState: stateAbbreviation)
        tableView.backgroundView = blurredBackgroundView
        navigationItem.title = fullStateName.capitalized
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("*** Receiving Memory Warning from HighwayListViewController!")
        
    }

    
    func registerNibs(){
        var nib = UINib(nibName: CustomCellTypeIdentifiers.CellWithImageView, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CustomCellTypeIdentifiers.CellWithImageView)
        nib = UINib(nibName: CustomCellTypeIdentifiers.NoRestStopsCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CustomCellTypeIdentifiers.NoRestStopsCell)
    }
    
    func numberOfRestStops(forRoute route: String) -> Int{
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: "USRestStop")
        let entity = NSEntityDescription.entity(forEntityName: "USRestStop", in: managedObjectContext)
        let predicate1 = NSPredicate(format: "routeName = %@", route)
        let predicate2 = NSPredicate(format: "state = %@", stateAbbreviation)
        let compoundPredicate = NSCompoundPredicate(type: NSCompoundPredicate.LogicalType.and, subpredicates:[predicate1, predicate2])
        fetchRequest.predicate = compoundPredicate
        fetchRequest.entity = entity
        do{
            let managedObjects = try managedObjectContext.fetch(fetchRequest)
            return managedObjects.count
        } catch let error as NSError{
            print(error.description)
            fatalError("Failed to fetch managed objects to get number of rest stops per route!")
        }
    }
    
    //MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowRestStopListMapView"{
            let cell = sender as! CellWithImageView
            let routeName = cell.stateNameLabel.text!
            let restStopListMapViewController = segue.destination as! RestStopListMapViewController
            restStopListMapViewController.state = self.stateAbbreviation
            restStopListMapViewController.managedObjectContext = self.managedObjectContext
            restStopListMapViewController.route = routeName
            restStopListMapViewController.appWindow = appWindow
            restStopListMapViewController.fullStateName = fullStateName
        }
    }
}

extension HighwayListViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if state == "Alaska" || state == "Hawaii" || state == "District of Columbia"{
            return 1
        } else {
            return routes.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if state == "Alaska" || state == "Hawaii" || state == "District of Columbia"{
            let cell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.NoRestStopsCell, for: indexPath) as! NoRestStopsCell
            cell.backgroundColor = UIColor.clear
            return cell
            
        } else {
            print("*** ROUTE NAME IS: \(routes[indexPath.row])")
            let cell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.CellWithImageView, for: indexPath) as! CellWithImageView
            cell.configureCell(forHighway: routes[indexPath.row], stateAbbreviation: stateAbbreviation, numberOfRestStops: numberOfRestStops(forRoute: routes[indexPath.row]))
            return cell
        }
    }
}
extension HighwayListViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if routes.count == 0 {
            return nil
        } else {
            return indexPath
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if routes.count == 0 {
            return
        } else {
            let cell = tableView.cellForRow(at: indexPath) as! CellWithImageView
            performSegue(withIdentifier: "ShowRestStopListMapView", sender: cell)
        }
    }
}

extension HighwayListViewController: NSFetchedResultsControllerDelegate{}


