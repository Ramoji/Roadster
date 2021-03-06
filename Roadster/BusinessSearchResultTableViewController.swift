
//  Copyright © 2016 A Ja. All rights reserved.
//

import UIKit
import YelpAPI
import CoreLocation
import CoreData
import Dispatch
import MapKit

protocol BusinessSearchResultTableViewControllerDelegate: class {
    func businessSearchResultTableViewStartedGettingBusiness(_ searchResultTable: BusinessSearchResultTableViewController)
    func businessSearchResultTableViewStopedGettingBusiness(_ searchResultTable: BusinessSearchResultTableViewController, with searchResultList: [AnyObject], at currentLocation: CLLocationCoordinate2D)
    func businessSearchResultTableViewDidSelectRow(_ searchResultTable: BusinessSearchResultTableViewController, with poi: AnyObject, and currentLocation: CLLocation)
    func businessSearchResultTableViewControllerNeedsUpdatedMapRegion(_ searchResultTable: BusinessSearchResultTableViewController) -> MKCoordinateRegion
    func businessSearchResultTableViewControllerSearchBarDidBeginEditing(_ searchResultTable: BusinessSearchResultTableViewController)
    
}

class BusinessSearchResultTableViewController: UIViewController{

    @IBOutlet weak var tableView: UITableView!
    
    var delegate: BusinessSearchResultTableViewControllerDelegate?
    
    var searchTerm: String = "" //Search term fed into Yelp API
    
    var POIList: [AnyObject] = [] //POI stands for "points of interest"
    
    var tableViewDataSourceList: [AnyObject] = []
    
    var shouldUpdateTableView: Bool = true
    
    var managedObjectContext: NSManagedObjectContext!
    
    var globalQueue = DispatchQueue.global(qos: .userInitiated)
    
    var mainQueue = DispatchQueue.main
    
    var headerView: UIView!
    
    var currentUserLocation: CLLocation! //Current device location updated by NearByViewController
    
    let searchBar = UISearchBar(frame: CGRect.zero)
    
    let searchCompleter = MKLocalSearchCompleter()
    
    var searchHistory: [AnyObject] = []
    
    var addressDetector: NSDataDetector!
    
    var searchTimer: Timer!
    
    var queryTerm = ""
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let blurredBackgroundView = BlurredBackgroundView(frame: self.view.bounds, addBackgroundPic: true)
        tableView.backgroundView = blurredBackgroundView
        initiateAddressDestector()
        registerNibs()
        setUpSearchBar()
        setUpHeaderView()
        setUpTableView()
        extendedLayoutIncludesOpaqueBars = true
        setUpSearchCompleter()
        unArchiveSearchHistory()
        loadSearchHistory()
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that have been recreated.
    }
    
    override func loadView() {
        super.loadView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func addToSearchHistory(_ element: AnyObject){
        
        if searchHistory.count == 20 {
            _ = searchHistory.popLast()
        }
        
        for (index, historyElement) in searchHistory.enumerated() {
            
            if element is USRestStop && historyElement is HistoryUSRestStop{
                let castedElement = element as! USRestStop
                let castedHistoryElement = historyElement as! HistoryUSRestStop
                if castedElement.latitude == castedHistoryElement.latitude && castedElement.longitude == castedHistoryElement.longitude{
                    searchHistory.remove(at: index)
                    searchHistory.insert(historyElement, at: 0)
                    archiveSearchHistory()
                    return
                }
            }
            
            if element is YLPBusiness && historyElement is HistoryYelpBusiness{
                let castedElement = element as! YLPBusiness
                let castedHistoryElement = historyElement as! HistoryYelpBusiness
                if castedElement.identifier == castedHistoryElement.businessIdentifier{
                    searchHistory.remove(at: index)
                    searchHistory.insert(historyElement, at: 0)
                    archiveSearchHistory()
                    return
                }
                
            }
            
            if element is MKMapItem && historyElement is FavoriteLocation{
                let castedElement = element as! MKMapItem
                let placemark = castedElement.placemark
                let castedFavoriteLocation = historyElement as! FavoriteLocation
                
                var streetAddress1: String {
                    if let subThoro = placemark.subThoroughfare{
                        return subThoro
                    } else {return ""}
                }
                
                var street1: String {
                    if let thoro = placemark.thoroughfare{
                       return thoro
                    } else {return ""}
                }
                
                var city1: String{
                    if let administrative = placemark.administrativeArea{
                        return administrative
                    } else {return ""}
                }
                
                var country1: String{
                    if let country = placemark.country{
                        return country
                    } else {return ""}
                }
                
                var streetAddress2: String {
                    if let subThoro = castedFavoriteLocation.placemark.subThoroughfare{
                        return subThoro
                    } else {return ""}
                }
                
                var street2: String {
                    if let thoro = castedFavoriteLocation.placemark.thoroughfare{
                        return thoro
                    } else {return ""}
                }
                
                var city2: String{
                    if let administrative = castedFavoriteLocation.placemark.administrativeArea{
                        return administrative
                    } else {return ""}
                }
                
                var country2: String{
                    if let country = castedFavoriteLocation.placemark.country{
                        return country
                    } else {return ""}
                }
                
                if street1 == street2 && street1 == street2 && city1 == city2 && country1 == country2{
                    searchHistory.remove(at: index)
                    searchHistory.insert(historyElement, at: 0)
                    archiveSearchHistory()
                    return
                }
            }
        }
        
        if element is YLPBusiness{
            let historyYelpBusiness = HistoryYelpBusiness(business: element as! YLPBusiness)
            searchHistory.insert(historyYelpBusiness, at: 0)
        } else if element is USRestStop{
            let historyUSRestStop = HistoryUSRestStop(restStop: element as! USRestStop)
            searchHistory.insert(historyUSRestStop, at: 0)
        } else if element is MKMapItem{
            let castedMapItem = element as! MKMapItem
            let favoriteLocation = FavoriteLocation(placemark: castedMapItem.placemark, locationName: castedMapItem.placemark.name)
            searchHistory.insert(favoriteLocation, at: 0)
        }
        
        archiveSearchHistory()
    }
    
    func initiateAddressDestector(){
        
        let types: NSTextCheckingResult.CheckingType = [.address]
        
        do{
            addressDetector = try NSDataDetector(types: types.rawValue)
        } catch {
            print("*** error is: \(error.localizedDescription)")
            fatalError()
        }
        
    }
    
   
    
    func loadSearchHistory(){
        tableViewDataSourceList = searchHistory
        let businessSearchResultFirstCell = BusinessSearchResultFirstCell()
        let searchHistoryCell = SearchHistoryCell()
        tableViewDataSourceList.insert(businessSearchResultFirstCell, at: 0)
        tableViewDataSourceList.insert(searchHistoryCell, at: 1)
        
        tableView.reloadData()
    }
    
    func timerDidFire(_ sender: Any){
        if searchCompleter.isSearching{
            searchCompleter.cancel()
            searchCompleter.region = (delegate?.businessSearchResultTableViewControllerNeedsUpdatedMapRegion(self))!
            searchCompleter.queryFragment = queryTerm
        } else {
            searchCompleter.region = (delegate?.businessSearchResultTableViewControllerNeedsUpdatedMapRegion(self))!
            searchCompleter.queryFragment = queryTerm
        }
    }
    

    
    //MARK: - SetUps
    func setUpHeaderView(){
        
        headerView = UIView()
        view.addSubview(headerView)
        
        headerView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = headerView.topAnchor.constraint(equalTo: view.topAnchor)
        let heightConstraint = headerView.heightAnchor.constraint(equalToConstant: 50)
        let leadingConstraint = headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let trailingConstraint = headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        NSLayoutConstraint.activate([topConstraint, heightConstraint, leadingConstraint, trailingConstraint])
        
    
        
        let grabView = UIView()
        let separator = UIView()
        
        
        
        headerView.addSubview(grabView)
        grabView.backgroundColor = tableView.separatorColor
        grabView.layer.cornerRadius = 2.5
        grabView.translatesAutoresizingMaskIntoConstraints = false
        let grabViewWidthConstraint = grabView.widthAnchor.constraint(equalTo: headerView.widthAnchor, multiplier: 0.10)
        let grabViewHeightConstraint = grabView.heightAnchor.constraint(equalToConstant: 5)
        let grabViewTopConstraint = grabView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 5)
        let grabViewHorizonalConstraint = grabView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor)
        NSLayoutConstraint.activate([grabViewWidthConstraint, grabViewHeightConstraint, grabViewTopConstraint,grabViewHorizonalConstraint])
        
         headerView.addSubview(separator)
        separator.backgroundColor = tableView.separatorColor
        separator.translatesAutoresizingMaskIntoConstraints = false
        let seperatorBottomConstraint = separator.topAnchor.constraint(equalTo: headerView.bottomAnchor)
        let seperatorTrailingConstraint = separator.trailingAnchor.constraint(equalTo: headerView.trailingAnchor)
        let seperatorLeadingConstraint = separator.leadingAnchor.constraint(equalTo: headerView.leadingAnchor)
        let seperatorHeightConstraint = separator.heightAnchor.constraint(equalToConstant: 0.7)
        NSLayoutConstraint.activate([seperatorBottomConstraint, seperatorTrailingConstraint, seperatorLeadingConstraint, seperatorHeightConstraint])
        
        headerView.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        let searchBarTopConstraint = searchBar.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 7.0)
        let searchBarLeadingConstraint = searchBar.leadingAnchor.constraint(equalTo: headerView.leadingAnchor)
        let searchBarHeightConstraint = searchBar.heightAnchor.constraint(equalToConstant: 44.0)
        let searchBarWidthConstraint = searchBar.widthAnchor.constraint(equalToConstant: self.view.bounds.width)
        NSLayoutConstraint.activate([searchBarTopConstraint, searchBarLeadingConstraint, searchBarWidthConstraint, searchBarHeightConstraint])
        
        
    }
    
    func setUpTableView(){
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor)
        let leadingConstraint = tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let trailingConstraint = tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        
        let tableViewHeight = (self.view.bounds.height * 0.75) - 50
        
        let heightConstraint = tableView.heightAnchor.constraint(equalToConstant: tableViewHeight)
        
    
        NSLayoutConstraint.activate([topConstraint, leadingConstraint, trailingConstraint, heightConstraint])
        tableView.clipsToBounds = true
        tableView.backgroundColor = UIColor.clear
    }
    
    func registerNibs(){
        var nib = UINib(nibName: CustomCellTypeIdentifiers.YelpTableViewCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CustomCellTypeIdentifiers.YelpTableViewCell)
        nib = UINib(nibName: CustomCellTypeIdentifiers.UnorderedRestStopCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CustomCellTypeIdentifiers.UnorderedRestStopCell)
        nib = UINib(nibName: CustomCellTypeIdentifiers.BusinessSearchResultFirstCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CustomCellTypeIdentifiers.BusinessSearchResultFirstCell)
        nib = UINib(nibName: CustomCellTypeIdentifiers.addressMapItemCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CustomCellTypeIdentifiers.addressMapItemCell)
        nib = UINib(nibName: CustomCellTypeIdentifiers.LocationsAddressCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CustomCellTypeIdentifiers.LocationsAddressCell)
        nib = UINib(nibName: CustomCellTypeIdentifiers.historyAddressCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CustomCellTypeIdentifiers.historyAddressCell)
        nib = UINib(nibName: CustomCellTypeIdentifiers.searchHistoryCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CustomCellTypeIdentifiers.searchHistoryCell)
        
    }
    
    func setUpView(){
        view.addShadow(withCornerRadius: 15.0)
    }
    
    func setUpSearchCompleter(){
        
        searchCompleter.delegate = self
    }
    
    func setUpSearchBar(){
        searchBar.searchBarStyle = .minimal
        searchBar.delegate = self
        searchBar.placeholder = "Search for a place of interest"
    }
    
   
   
    
    func getBusinesses(withSearchTerm term: String, userCoordinates coordinate: CLLocationCoordinate2D){
        
        let ylpCoordinate = YLPCoordinate(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        globalQueue.async {
            YLPClient.authorize(withAppId: APICredentials.yelpAPI_ID, secret: APICredentials.yelpAPI_secret){
                client, error in
        
                client?.search(with: ylpCoordinate, term: term, limit: 20, offset: 0, sort: .distance){
                    search, error in
                    
                    if error != nil {
                        self.mainQueue.async {
                            let alert = UIAlertController(title: "Limited Service", message: "Unable to seatch for \(term)", preferredStyle: .alert)
                            let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                            alert.addAction(okAction)
                            self.present(alert, animated: true, completion: nil)
                        }
                    } else {
                        self.mainQueue.async {
                            self.POIList = (search?.businesses)!
                            if self.POIList.count != 0 && self.shouldUpdateTableView{
                                self.tableViewDataSourceList = self.POIList
                                self.tableView.reloadData()
                                self.delegate?.businessSearchResultTableViewStopedGettingBusiness(self, with: self.tableViewDataSourceList, at: CLLocationCoordinate2D(latitude: self.currentUserLocation.coordinate.latitude, longitude: self.currentUserLocation.coordinate.longitude))
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getNearByRestStops(lowerLeftCoordinate: CLLocationCoordinate2D, upperRightCoordinate: CLLocationCoordinate2D, userCoordinates: CLLocationCoordinate2D){

        let limitingCoordinateForRestStopQuery = getLimitingCoordinatesForNearbyRestStopQuery(with: currentUserLocation.coordinate)
        let localLowerLeftCoordinate = limitingCoordinateForRestStopQuery.lowerLeftCoordinate
        let localUpperRightCoordinate = limitingCoordinateForRestStopQuery.upperRightCoordinate
        
        let fetchRequest: NSFetchRequest<USRestStop> = {
            let fetchRequest = NSFetchRequest<USRestStop>()
            fetchRequest.entity = USRestStop.entity()
            let compoundPredicate = NSCompoundPredicate(type: .and, subpredicates: [NSPredicate(format: "latitude BETWEEN {%@, %@}", argumentArray: [localLowerLeftCoordinate.latitude, localUpperRightCoordinate.latitude]), NSPredicate(format: "longitude BETWEEN {%@, %@}", argumentArray: [localLowerLeftCoordinate.longitude, localUpperRightCoordinate.longitude])])
            fetchRequest.predicate = compoundPredicate
            fetchRequest.fetchBatchSize = 100
            fetchRequest.entity = USRestStop.entity()
            return fetchRequest
        }()
        
        do{
             POIList = try managedObjectContext.fetch(fetchRequest)
            
            if POIList.count != 0 && shouldUpdateTableView{
                tableViewDataSourceList = POIList
                tableView.reloadData()
                delegate?.businessSearchResultTableViewStopedGettingBusiness(self, with: tableViewDataSourceList, at: CLLocationCoordinate2D(latitude: currentUserLocation.coordinate.latitude, longitude: currentUserLocation.coordinate.longitude))
            }
            
        }catch let error as NSError{
            print(error.debugDescription)
            fatalError("Fetching close restStops failed!")
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        headerView.removeFromSuperview()
        setUpHeaderView()
        setUpTableView()
        setUpView()
    }
    
    func getLimitingCoordinatesForNearbyRestStopQuery(with userCurrentLocation: CLLocationCoordinate2D) -> (lowerLeftCoordinate: CLLocationCoordinate2D, upperRightCoordinate: CLLocationCoordinate2D){
        
        let mapRegion = MKCoordinateRegionMakeWithDistance(userCurrentLocation, 80467, 80467)
        let deltaRegion = MKCoordinateRegionMakeWithDistance(userCurrentLocation, 80467, 80467)
        var lowerLeft = CLLocationCoordinate2D()
        var upperRight = CLLocationCoordinate2D()
        upperRight.latitude = mapRegion.center.latitude + 0.5 * deltaRegion.span.latitudeDelta
        lowerLeft.latitude = mapRegion.center.latitude - 0.5 * deltaRegion.span.latitudeDelta
        upperRight.longitude = mapRegion.center.longitude + 0.5 * deltaRegion.span.longitudeDelta
        lowerLeft.longitude = mapRegion.center.longitude - 0.5 * deltaRegion.span.longitudeDelta
        return (lowerLeftCoordinate: lowerLeft, upperRightCoordinate: upperRight)
    }
    
    func archiveSearchHistory(){
        var searchHistoryDataPath = ""
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
            searchHistoryDataPath = documentsDirectory.appendingPathComponent("archive").path
        }
        
        if NSKeyedArchiver.archiveRootObject(searchHistory, toFile: searchHistoryDataPath){
            print("Succeded in archiving search history!")
        } else {
            fatalError("Failed to archive search history!")
        }
    }
    
    func unArchiveSearchHistory(){
        
        var searchHistoryDataPath = ""
        if let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first{
            searchHistoryDataPath = documentsDirectory.appendingPathComponent("archive").path
            
            guard FileManager.default.fileExists(atPath: searchHistoryDataPath) else {return}
            
            let history = NSKeyedUnarchiver.unarchiveObject(withFile: searchHistoryDataPath) as! [AnyObject]
            searchHistory = history
            
        }
    }
    
    func addServiceCellToTableView(){
        for element in tableViewDataSourceList{
            if element is BusinessSearchResultFirstCell{return}
        }
        let serviceCell = BusinessSearchResultFirstCell(style: .default, reuseIdentifier: CustomCellTypeIdentifiers.BusinessSearchResultFirstCell)
        tableViewDataSourceList.insert(serviceCell, at: 0)
        tableView.reloadData()
    }
    
    func removeServiceCellFromTableView(){
        guard !tableViewDataSourceList.isEmpty else {return}
        for (index, element) in tableViewDataSourceList.enumerated(){
            if element is BusinessSearchResultFirstCell{
                tableViewDataSourceList.remove(at: index)
            }
        }
        tableView.reloadData()
    }
    
    func searchAddress(for string: String){
        
        let localSearchRequest = MKLocalSearchRequest()
        localSearchRequest.naturalLanguageQuery = string
        localSearchRequest.region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude: currentUserLocation.coordinate.latitude, longitude: currentUserLocation.coordinate.longitude), 500000, 500000)
        let localSearch = MKLocalSearch(request: localSearchRequest)
        localSearch.start(completionHandler: {searchResponse, error in
            guard error == nil else {
                print(error.debugDescription)
                return
            }
            
            guard let mapItems = searchResponse?.mapItems else {return}
            
            self.tableViewDataSourceList = mapItems
            self.tableView.reloadData()
            self.delegate?.businessSearchResultTableViewStopedGettingBusiness(self, with: self.tableViewDataSourceList, at: CLLocationCoordinate2D(latitude: self.currentUserLocation.coordinate.latitude, longitude: self.currentUserLocation.coordinate.longitude))
        })
    }
    
    deinit {
        
        print("*** BusinessSearchResultTableViewController deinitialized!")
    }
    
}

extension BusinessSearchResultTableViewController: UITableViewDataSource{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tableViewDataSourceList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell!
        
        let element = tableViewDataSourceList[indexPath.row]
        
        if element is USRestStop{
            let restStop = element as! USRestStop
            let restStopCLLocation = CLLocation(latitude: restStop.latitude, longitude: restStop.longitude)
            let distanceFromUser = Int(restStopCLLocation.distance(from: currentUserLocation) / 1609.34)
            let restStopCell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.UnorderedRestStopCell, for: indexPath) as! UnorderedRestStopCell
            restStopCell.configureCell(with: restStop, distanceFromUser: distanceFromUser)
            cell = restStopCell
            
        } else if element is YLPBusiness{
            let business = element as! YLPBusiness
            let yelpTableViewCell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.YelpTableViewCell, for: indexPath) as! YelpTableViewCell
            yelpTableViewCell.setUp(for: business)
            cell = yelpTableViewCell
            
        } else if element is HistoryUSRestStop{
            let restStop = element as! HistoryUSRestStop
            let restStopCLLocation = CLLocation(latitude: restStop.latitude, longitude: restStop.longitude)
            let distanceFromUser = Int(restStopCLLocation.distance(from: currentUserLocation) / 1609.34)
            let restStopCell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.UnorderedRestStopCell, for: indexPath) as! UnorderedRestStopCell
            restStopCell.configureHistoryCell(with: restStop, distanceFromUser: distanceFromUser)
            cell = restStopCell
            
        } else if element is HistoryYelpBusiness{
            let business = element as! HistoryYelpBusiness
            let yelpTableViewCell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.YelpTableViewCell, for: indexPath) as! YelpTableViewCell
            yelpTableViewCell.setUpHistoryCell(for: business)
            cell = yelpTableViewCell
            
        } else if element is BusinessSearchResultFirstCell{
            let serviceCell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.BusinessSearchResultFirstCell, for: indexPath) as! BusinessSearchResultFirstCell
            serviceCell.separatorInset = UIEdgeInsets(top: 0, left: self.view.bounds.width, bottom: 0, right: 0)
            serviceCell.delegate = self
            cell = serviceCell
            
        } else if element is MKMapItem{
            let addressCell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.addressMapItemCell, for: indexPath) as! AddressMapItemCell
            addressCell.configureCell(for: element as! MKMapItem)
            cell = addressCell
            
        } else if element is FavoriteLocation{
            let addressCell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.historyAddressCell, for: indexPath) as! HistoryAddressCell
            let favoriteLocation = element as! FavoriteLocation
            addressCell.configureCell(for: favoriteLocation, and: currentUserLocation)
            cell = addressCell
            
        } else if element is SearchHistoryCell{
            let searchHistoryCell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.searchHistoryCell, for: indexPath) as! SearchHistoryCell
            searchHistoryCell.configureCell()
            cell = searchHistoryCell
        }
        
        return cell
    }
    
}

extension BusinessSearchResultTableViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 && tableViewDataSourceList[indexPath.row] is BusinessSearchResultFirstCell{
            return 164
        } else if tableViewDataSourceList[indexPath.row] is MKMapItem{
            return 62
        } else if indexPath.row == 1 && tableViewDataSourceList[indexPath.row] is SearchHistoryCell{
            return 22
        } else {
            return 84
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var selectedElement: AnyObject {
            return tableViewDataSourceList[indexPath.row]
        }
        
        
        addToSearchHistory(selectedElement)
        
        searchBar.resignFirstResponder()
        delegate?.businessSearchResultTableViewDidSelectRow(self, with: selectedElement, and: currentUserLocation)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == tableView.indexPathsForVisibleRows?.last?.row{
            shouldUpdateTableView = true
        } else {
            shouldUpdateTableView = false
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if indexPath.row == 0 && tableViewDataSourceList[indexPath.row] is BusinessSearchResultFirstCell{
            return nil
        } else {return indexPath}
    }
    
    func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?){
        tableView.reloadData()
    }
    
}


extension BusinessSearchResultTableViewController: UISearchBarDelegate{
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == "" {
            addServiceCellToTableView()
            loadSearchHistory()
            return
        } else if searchBar.text != "" {
            removeServiceCellFromTableView()
            queryTerm = searchText
        }
        
        
        if let searchTimer = searchTimer{
            searchTimer.invalidate()
        }
        
        searchTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(timerDidFire(_:)), userInfo: nil, repeats: false)
        
       
        
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        
        
        addServiceCellToTableView()
        loadSearchHistory()
        if tableViewDataSourceList.count != 0 {
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        delegate?.businessSearchResultTableViewControllerSearchBarDidBeginEditing(self)
    }
    
    
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.setShowsCancelButton(false, animated: true)
        searchBar.text = ""
        
        addServiceCellToTableView()
        
        loadSearchHistory()
    }
}

extension BusinessSearchResultTableViewController: MKLocalSearchCompleterDelegate{
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter){
        
        guard completer.results.count != 0 else {return}
        
        var searchTerm: String = completer.results.first!.title
        if completer.results.first!.subtitle != "" {
            searchTerm = searchTerm + ", " + completer.results.first!.subtitle
        }
        
        
        if let _ = addressDetector.firstMatch(in: searchTerm, options: [], range: NSMakeRange(0, searchTerm.utf8.count)){
            searchAddress(for: searchTerm)
        } else {
            getBusinesses(withSearchTerm: searchTerm, userCoordinates: currentUserLocation.coordinate)
        }
    
        
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error){
        
        print(error.localizedDescription)
        searchCompleter.cancel()
        shouldUpdateTableView = true
        
    }
}

extension BusinessSearchResultTableViewController: BusinessSearchResultFirstCellDelegate{
    func didTapServiceButton(businessSearchResultFirstCell cell: BusinessSearchResultFirstCell, _ sender: UIButton) {
        shouldUpdateTableView = true
        if cell.bankButton === sender{
            searchTerm = "Bank"

        } else if cell.coffeeButton === sender{
            searchTerm = "Coffee Shop"
            
        } else if cell.foodButton === sender{
            searchTerm = "Food"
            
        } else if cell.gasButton === sender{
            searchTerm = "Gas Station"
            
        } else if cell.groceryButton === sender{
            searchTerm = "Grocery"
            
        } else if cell.hospitalButton === sender{
            searchTerm = "Hospital"
            
        } else if cell.postButton === sender{
            searchTerm = "Post Office"
            
        } else {
            getNearByRestStops(lowerLeftCoordinate: CLLocationCoordinate2DMake(0, 0), upperRightCoordinate: CLLocationCoordinate2DMake(0, 0), userCoordinates: currentUserLocation.coordinate)
            return
        }
        
        
        getBusinesses(withSearchTerm: searchTerm, userCoordinates: currentUserLocation.coordinate)
        
    }
}






