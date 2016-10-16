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
    var states: States!
    var stateName: String!
    var stateAbbreviation: String!
    var routes: [String] = [String]()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerNibs()
        getUniqueRouteNames()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func getUniqueRouteNames(){
        stateAbbreviation = states.abbreviation(for: stateName)
        let entity = NSEntityDescription.entity(forEntityName: "USRestStop", in: managedObjectContext)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "USRestStop")
        let predicate = NSPredicate(format: "state == %@", stateAbbreviation)
        let sortDescriptor = NSSortDescriptor(key: "routeName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        fetchRequest.entity = entity
        fetchRequest.resultType = .dictionaryResultType
        fetchRequest.returnsDistinctResults = true
        fetchRequest.propertiesToFetch = ["routeName"]
        
        do{
            let objects = try managedObjectContext.fetch(fetchRequest)
            for element in objects{
                let element2 = element as! [String: String]
                routes.append(element2["routeName"]!)
            }
            routes.sort(by: {
                return $0.localizedStandardCompare($1) == ComparisonResult.orderedAscending
            })
            
            
        } catch {
            fatalError("The fetch failed")
        }
    }
    
    
    func registerNibs(){
        var nib = UINib(nibName: CustomCellTypeIdentifiers.CellWithImageView, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CustomCellTypeIdentifiers.CellWithImageView)
        nib = UINib(nibName: CustomCellTypeIdentifiers.NoRestStopsCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CustomCellTypeIdentifiers.NoRestStopsCell)
    }
    
    //MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowListRestStops"{
            let cell = sender as! CellWithImageView
            let routeName = cell.stateNameLabel.text!
            let restStopListViewController = segue.destination as! RestStopListViewController
            restStopListViewController.stateAbbreviation = self.stateAbbreviation
            restStopListViewController.managedObjectContext = self.managedObjectContext
            restStopListViewController.states = self.states
            restStopListViewController.routeName = routeName
        }
    }
}

extension HighwayListViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if stateName == "Alaska" || stateName == "Hawaii" || stateName == "District of Columbia"{
            return 1
        } else {
            return routes.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if stateName == "Alaska" || stateName == "Hawaii" || stateName == "District of Columbia"{
            let cell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.NoRestStopsCell, for: indexPath) as! NoRestStopsCell
            return cell
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.CellWithImageView, for: indexPath) as! CellWithImageView
            cell.stateNameLabel.text = routes[indexPath.row]
            cell.imageView?.isHidden = true
            cell.nicknameLabel.isHidden = true
            return cell
        }
    }
}
extension HighwayListViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! CellWithImageView
        performSegue(withIdentifier: "ShowListRestStops", sender: cell)
    }
}

extension HighwayListViewController: NSFetchedResultsControllerDelegate{}


