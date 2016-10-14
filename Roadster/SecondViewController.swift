//
//  SecondViewController.swift
//  Roadster
//
//  Created by A Ja on 9/6/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

import UIKit
import CoreData

class SecondViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
     var managedObjectContext: NSManagedObjectContext!
    
    lazy var fetchedResultsController: NSFetchedResultsController<USRestStop> = {
        
        let fetchRequest = NSFetchRequest<USRestStop>()
        let entity = USRestStop.entity()
        fetchRequest.entity = entity
        let sortDescriptor = NSSortDescriptor(key: "state", ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "routeName", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor, sortDescriptor2]
        fetchRequest.fetchBatchSize = 100
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: "USRestStops")
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsets(top: 60, left: 0, bottom: 0, right: 0)
        performFetch()
        registerNibs()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func showTableView(_ sender: UIButton){
        performSegue(withIdentifier: "X", sender: sender)
    }
    
    func performFetch(){
        do{
            try fetchedResultsController.performFetch()
        }catch let error as NSError{
            print(error.debugDescription)
            fatalError("There was an error when fetching values from the data base")
        }
    }
    
    func registerNibs(){
        let nib = UINib(nibName: "CellWithImageView", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CellWithImageView")
    }
}

extension SecondViewController: UITableViewDataSource{
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections![section].numberOfObjects
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellWithImageView", for: indexPath) as! CellWithImageView
        let object = fetchedResultsController.object(at: indexPath)
        cell.stateNameLabel.text = object.state
        cell.nicknameLabel.text = object.routeName
        return cell
    }
}
extension SecondViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 66.0
    }
}
extension SecondViewController: NSFetchedResultsControllerDelegate{}
