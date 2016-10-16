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
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        listOfRestStops = restStops(forContext: managedObjectContext)
        registerNibs()
        sortRestStopBound()
        setUpSegmentedControl()
        NBlistOfRestStops = sortBasedOnLatitudeLongitude(forList: NBlistOfRestStops, forBound: .NB)
        SBlistOfRestStops = sortBasedOnLatitudeLongitude(forList: SBlistOfRestStops, forBound: .SB)
        EBlistOfRestStops = sortBasedOnLatitudeLongitude(forList: EBlistOfRestStops, forBound: .EB)
        WBlistOfRestStops = sortBasedOnLatitudeLongitude(forList: WBlistOfRestStops, forBound: .WB)
    }
    
    override func loadView() {
        super.loadView()
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
    
    func sortBasedOnLatitudeLongitude(forList list: [USRestStop], forBound bound: RouteBound) -> [USRestStop]{
        var sortedList: [USRestStop] = [USRestStop]()
        switch bound{
        case .NB:
            sortedList = list.sorted(by: { restStop1, restStop2 in
                return restStop1.latitude < restStop2.latitude
            })
        case .SB:
            sortedList = list.sorted(by: { restStop1, restStop2 in
                return restStop1.latitude > restStop2.latitude
            })
        case .EB:
            sortedList = list.sorted(by: { restStop1, restStop2 in
                return restStop1.longitude < restStop2.longitude
            })
        case .WB:
            sortedList = list.sorted(by: { restStop1, restStop2 in
                return restStop1.longitude > restStop2.longitude
            })
        default:
            print("Sorting rest stops based on latitude and longitude failed!")
        }
        return sortedList
    }
    
    func setUpTableView(){
        
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func segmentedChangedValue(){
        tableView.reloadData()
    }
    
    func setUpSegmentedControl(){
        if !NBlistOfRestStops.isEmpty || !SBlistOfRestStops.isEmpty {
            segmentedControl.setTitle("North Bound", forSegmentAt: 0)
            segmentedControl.setTitle("South Bound", forSegmentAt: 1)
        } else if !EBlistOfRestStops.isEmpty || !WBlistOfRestStops.isEmpty{
            segmentedControl.setTitle("East Bound", forSegmentAt: 0)
            segmentedControl.setTitle("West Bound", forSegmentAt: 1)
        }
        segmentedControl.addTarget(self, action: #selector(segmentedChangedValue), for: UIControlEvents.valueChanged)
    }
    
}

extension RestStopListViewController:UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentedControl.selectedSegmentIndex == 0 && !NBlistOfRestStops.isEmpty{
            return NBlistOfRestStops.count
        } else if segmentedControl.selectedSegmentIndex == 1 && !SBlistOfRestStops.isEmpty{
            return SBlistOfRestStops.count
        } else if segmentedControl.selectedSegmentIndex == 0 && !EBlistOfRestStops.isEmpty{
            return EBlistOfRestStops.count
        } else if segmentedControl.selectedSegmentIndex == 1 && !WBlistOfRestStops.isEmpty {
            return WBlistOfRestStops.count
        } else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.CellWithImageView, for: indexPath) as! CellWithImageView
        if segmentedControl.selectedSegmentIndex == 0 && !NBlistOfRestStops.isEmpty{
            cell.stateNameLabel.text = NBlistOfRestStops[indexPath.row].bound
            cell.nicknameLabel.text = String(NBlistOfRestStops[indexPath.row].latitude) + ", " + String(NBlistOfRestStops[indexPath.row].longitude)
        } else if segmentedControl.selectedSegmentIndex == 1 && !SBlistOfRestStops.isEmpty{
            cell.stateNameLabel.text = SBlistOfRestStops[indexPath.row].bound
            cell.nicknameLabel.text = String(SBlistOfRestStops[indexPath.row].latitude) + ", " + String(SBlistOfRestStops[indexPath.row].longitude)
        } else if segmentedControl.selectedSegmentIndex == 0 && !EBlistOfRestStops.isEmpty{
            cell.stateNameLabel.text = EBlistOfRestStops[indexPath.row].bound
            cell.nicknameLabel.text = String(EBlistOfRestStops[indexPath.row].latitude) + ", " + String(EBlistOfRestStops[indexPath.row].longitude)
        } else if segmentedControl.selectedSegmentIndex == 1 && !WBlistOfRestStops.isEmpty {
            cell.stateNameLabel.text = WBlistOfRestStops[indexPath.row].bound
            cell.nicknameLabel.text = String(WBlistOfRestStops[indexPath.row].latitude) + ", " + String(WBlistOfRestStops[indexPath.row].longitude)
        } else {
            cell.stateNameLabel.text = ""
            cell.nicknameLabel.text = ""
        }
        return cell
    }
}
extension RestStopListViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66
    }
}

