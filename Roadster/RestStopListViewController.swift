//
//  RestStopListViewController.swift
//  Roadster
//
//  Created by A Ja on 10/12/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

enum RouteBound: String{
    case NB = "NB"
    case SB = "SB"
    case EB = "EB"
    case WB = "WB"
    case NBandSB = "NB/SB"
    case SBandNB = "SB/NB"
    case EBandWB = "EB/WB"
}

import UIKit
import CoreData

class RestStopListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var NBlistOfRestStops:[USRestStop] = [USRestStop]()
    var SBlistOfRestStops:[USRestStop] = [USRestStop]()
    var EBlistOfRestStops:[USRestStop] = [USRestStop]()
    var WBlistOfRestStops:[USRestStop] = [USRestStop]()
    var listOfRestStops:[USRestStop]!
    var managedObjectContext: NSManagedObjectContext!
    var stateAbbreviation: String!
    var states: States!
    var routeName: String!
    var segmentedControl: UISegmentedControl!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        listOfRestStops = restStops(forContext: managedObjectContext)
        registerNibs()
        sortRestStopBound()
        NBlistOfRestStops = sortArrayBasedOnLatitude(forList: NBlistOfRestStops)
        for restStop in NBlistOfRestStops{
            print(restStop.longitude)
        }
        
        setUpTableView()
        view.addSubview(segmentedControl)
        
        
    }
    
    override func loadView() {
        super.loadView()
        segmentedControl = UISegmentedControl(items: ["One", "Two"])
        segmentedControl.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: 20)
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func restStops(forContext context: NSManagedObjectContext) -> [USRestStop]{
        var array = [USRestStop]()
        let fetchRequest = NSFetchRequest<USRestStop>()
        let predicate = NSCompoundPredicate(format: "state == %@ AND routeName == %@", stateAbbreviation, routeName)
        fetchRequest.fetchBatchSize = 100
        fetchRequest.entity = USRestStop.entity()
        fetchRequest.predicate = predicate
        do{
            array = try managedObjectContext.fetch(fetchRequest)
        }catch let error as NSError{
            print(error.debugDescription)
            fatalError("Failed to fetch rest stops from the data store!")
        }
        return array
    }
    
    func registerNibs(){
        let nib = UINib(nibName: CustomCellTypeIdentifiers.CellWithImageView, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CustomCellTypeIdentifiers.CellWithImageView)
    }
    
    func sortRestStopBound(){
        if let listOfRestStops = listOfRestStops{
            for restStop in listOfRestStops{
                switch restStop.bound {
                case RouteBound.NB.rawValue:
                    NBlistOfRestStops.append(restStop)
                case RouteBound.SB.rawValue:
                    SBlistOfRestStops.append(restStop)
                case RouteBound.EB.rawValue:
                    EBlistOfRestStops.append(restStop)
                case RouteBound.WB.rawValue:
                    WBlistOfRestStops.append(restStop)
                case RouteBound.NBandSB.rawValue:
                    NBlistOfRestStops.append(restStop)
                    SBlistOfRestStops.append(restStop)
                case RouteBound.SBandNB.rawValue:
                    NBlistOfRestStops.append(restStop)
                    SBlistOfRestStops.append(restStop)
                case RouteBound.EBandWB.rawValue:
                    EBlistOfRestStops.append(restStop)
                    WBlistOfRestStops.append(restStop)
                default:
                    fatalError("Error sorting route bound in RestStopListViewController!")
                }
            }
        }
    }
    
    func sortArrayBasedOnLatitude(forList list: [USRestStop]) -> [USRestStop]{
        let sortedList = list.sorted(by: { restStop1, restStop2 in
            return restStop1.longitude > restStop2.longitude
        })
        return sortedList
    }
    
    func setUpTableView(){
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}

extension RestStopListViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listOfRestStops.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.CellWithImageView, for: indexPath) as! CellWithImageView
        cell.stateNameLabel.text = listOfRestStops[indexPath.row].stopName
        cell.nicknameLabel.text = listOfRestStops[indexPath.row].bound
        return cell
    }
}
extension RestStopListViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
}
