//
//  BusinessDetailChildTableViewController.swift
//  Roadster
//
//  Created by EA JA on 7/12/17.
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit
import YelpAPI
import Alamofire
import AlamofireImage
import CoreLocation
import MapKit
import SwiftyJSON
import Dispatch
import Contacts



struct BusinessDetailChildTableViewControllerCellIdentifiers {
    static let imagesCell = "imagesCell"
    static let yelpWebPageCell = "yelpWebPageCell"
    static let phoneCell = "phoneCell"
    static let addressCell = "addressCell"
    static let hoursCell = "hoursCell"
    static let addToFavoritesCell = "addToFavoritesCell"
}

struct YelpComment{
    var rating: Double?
    var userImageURL: String?
    var comment: String?
    var commentDate: Date?
    var commentPageURL: String?
    var userName: String?
}

class BusinessDetailChildTableViewController: UITableViewController {
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageView2: UIImageView!
    @IBOutlet weak var imageView3: UIImageView!
    var imageViews: [UIImageView]!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var websiteLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var mondayHoursLabel: UILabel!
    @IBOutlet weak var tuesdayHoursLabel: UILabel!
    @IBOutlet weak var wednesdayHoursLabel: UILabel!
    @IBOutlet weak var thursdayHoursLabel: UILabel!
    @IBOutlet weak var fridayHoursLabel: UILabel!
    @IBOutlet weak var saturdayHoursLabel: UILabel!
    @IBOutlet weak var sundayHoursLabel: UILabel!
    @IBOutlet weak var businessHoursNotAvailableLabel: UILabel!
    
    var directions: MKDirections!
    @IBOutlet weak var directionsButton: UIButton!
    @IBOutlet weak var websiteButton: UIButton!
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var exportButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    
    var business: Business!
    let geocoder: CLGeocoder = CLGeocoder()
    var activityViewController: UIActivityViewController!
    
    @IBOutlet weak var weekDaysStackView: UIStackView!
    @IBOutlet weak var hoursStackView: UIStackView!
    
    var sectionOneHeaderViewContainer: UIView!
    
    var comments: [YelpComment] = []
    var favoriteBusinesses: [HistoryYelpBusiness] = []
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        imageViews = [imageView1, imageView2, imageView3]
        registerNibs()
        tableView.backgroundColor = UIColor.clear
        setupTableView()
        
        favoriteButton.isHidden = false
        favoriteButton.contentMode = .scaleAspectFit
    }
    
    func setupTableView(){
        sectionOneHeaderViewContainer = getSectionOneHeaderView()
        loadFavoriteBusinessesList()
        if let business = self.business{
            updateTableView(with: business)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("*** in business detail child view contorller viewDidAppear(:)!")
        loadFavoriteBusinessesList()
        if let business = self.business{
            updateTableView(with: business)
        }
    }

    func loadYelpComments(){
        guard let business = business else {return}
        guard let _ = tableView else {return}
        guard let businessID = business.id else {return}
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        
        HTTPHelper.shared.getYelpComments(for: businessID, completionHandlers: { data in
            let json = JSON(data)
            let reviews = json["reviews"].arrayValue.map({return $0.dictionaryValue})
            var commentDate: Date?
            
            var yelpComments: [YelpComment] = []
            
            for (index, review) in reviews.enumerated(){
                let userDictionary = review["user"]?.dictionary
                if let dateString = review["time_created"]?.stringValue{
                    commentDate = dateFormatter.date(from: dateString)
                }
                
                let yelpComment = YelpComment(rating: review["rating"]?.doubleValue, userImageURL: userDictionary?["image_url"]?.stringValue, comment: review["text"]?.stringValue, commentDate: commentDate, commentPageURL: review["url"]?.stringValue, userName: userDictionary?["name"]?.stringValue)
                
                yelpComments.append(yelpComment)
            }
            self.comments = yelpComments
            self.tableView.reloadData()
        })
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func makePhoneCall(_ sender: UIButton){
        if let phoneNumber = business.phone, let phoneURL = URL(string: "tel://" + phoneNumber){
            UIApplication.shared.openURL(phoneURL)
        }
    }
    
    @IBAction func exportAddress(_ sender: Any) {
        
        var addressString = ""
        if let address = addressLabel.text{
            addressString = address
        }
        activityViewController = UIActivityViewController(activityItems: [addressString], applicationActivities: nil)
        
            if !activityViewController.isBeingPresented{
                present(activityViewController, animated: true, completion: nil)
            }
        
    }
    
    func registerNibs(){
        let nib = UINib(nibName: CustomCellTypeIdentifiers.YelpCommentCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CustomCellTypeIdentifiers.YelpCommentCell)
    }
    
    func getSectionOneHeaderView() -> UIView{
        let sectionOneHeaderView = UILabel()
        let headerAttributedString = NSAttributedString(string: "WHAT PEOPLE SAY", attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 12), NSForegroundColorAttributeName: UIColor.lightGray])
        sectionOneHeaderView.attributedText = headerAttributedString
        sectionOneHeaderView.sizeToFit()
        let headerViewContainer = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: sectionOneHeaderView.bounds.height + 10))
        sectionOneHeaderView.translatesAutoresizingMaskIntoConstraints = false
        headerViewContainer.addSubview(sectionOneHeaderView)
        let headerViewTopConstraint = sectionOneHeaderView.topAnchor.constraint(equalTo: headerViewContainer.topAnchor)
        let headerViewLeadingConstraint = sectionOneHeaderView.leadingAnchor.constraint(equalTo: headerViewContainer.leadingAnchor, constant: 18.0)
        let headerViewWidthConstraint = sectionOneHeaderView.widthAnchor.constraint(equalToConstant: sectionOneHeaderView.bounds.width)
        let headerViewHeightConstraint = sectionOneHeaderView.heightAnchor.constraint(equalToConstant: sectionOneHeaderView.bounds.height)
        NSLayoutConstraint.activate([headerViewTopConstraint, headerViewLeadingConstraint, headerViewWidthConstraint, headerViewHeightConstraint])
        
        let seperator = UIView()
        seperator.backgroundColor = UIColor.lightGray
        headerViewContainer.addSubview(seperator)
        seperator.translatesAutoresizingMaskIntoConstraints = false
        let seperatorBottomConstraint = seperator.bottomAnchor.constraint(equalTo: headerViewContainer.bottomAnchor)
        let seperatorLeadingConstraint = seperator.leadingAnchor.constraint(equalTo: headerViewContainer.leadingAnchor, constant: 15.0)
        let seperatorHeightConstraint = seperator.heightAnchor.constraint(equalToConstant: 0.5)
        let seperatorWidthConstraint = seperator.widthAnchor.constraint(equalToConstant: headerViewContainer.bounds.width - 15.0)
        
        NSLayoutConstraint.activate([seperatorBottomConstraint, seperatorLeadingConstraint, seperatorHeightConstraint, seperatorWidthConstraint])
        
        return headerViewContainer
    }

   
    func updateTableView(with business: Business){
        
        if let photos = business.photos{
            for (index, photoURL) in photos.enumerated(){
                if index >= imageViews.count {break}
                Alamofire.request(photoURL).responseImage{ response in
                    if let image = response.result.value{
                        self.imageViews[index].contentMode = .scaleAspectFill
                        self.imageViews[index].layer.masksToBounds = true
                        self.imageViews[index].image = image
                    }
                }
            }
        }
        
        if let hours = business.hours{
            businessHoursNotAvailableLabel.isHidden = true
            weekDaysStackView.isHidden = false
            hoursStackView.isHidden = false
            
            mondayHoursLabel.text = constructHoursString(weekDayHours: hours.monday)
            
            tuesdayHoursLabel.text = constructHoursString(weekDayHours: hours.tuesday)
            
            wednesdayHoursLabel.text = constructHoursString(weekDayHours: hours.wednesday)
            
            thursdayHoursLabel.text = constructHoursString(weekDayHours: hours.thursday)
            
            fridayHoursLabel.text = constructHoursString(weekDayHours: hours.friday)
            
            saturdayHoursLabel.text = constructHoursString(weekDayHours: hours.saturday)
            
            sundayHoursLabel.text = constructHoursString(weekDayHours: hours.sunday)
            
        } else {
            
            weekDaysStackView.isHidden = true
            hoursStackView.isHidden = true
            businessHoursNotAvailableLabel.isHidden = false
            
        }
        
        if let telephoneNumber = business.display_phone{
            phoneLabel.text = telephoneNumber
        }
        
        if let address = business.display_address{
            addressLabel.numberOfLines = 0
            addressLabel.lineBreakMode = .byWordWrapping
            addressLabel.textAlignment = .left
            
            if let latitude = business.latitude, let longitude = business.longitude{
                let businessCLLocation = CLLocation(latitude: latitude, longitude: longitude)
                geocoder.reverseGeocodeLocation(businessCLLocation){ placemarkArray, error in
                    
                    if error != nil{
                        self.addressLabel.text = address
                    } else {
                        if let placemark = placemarkArray?.last{
                            var addressString: String = ""
                            if let subThoroughFare = placemark.subThoroughfare{
                                addressString.append(subThoroughFare)
                            }
                            if let thoroughFare = placemark.thoroughfare{
                                addressString.append(", ")
                                addressString.append(thoroughFare)
                            }
                            
                            if let city = placemark.locality{
                                addressString.append(", ")
                                addressString.append(city)
                            }
                            
                            if let state = placemark.administrativeArea{
                                addressString.append(", ")
                                addressString.append(state)
                            }
                            
                            if let zipCode = placemark.postalCode{
                                addressString.append(" ")
                                addressString.append(zipCode)
                            }
                            
                            if let country = placemark.country{
                                addressString.append(", ")
                                addressString.append(country)
                            }
                            
                            self.addressLabel.text = addressString
                        } else {
                            self.addressLabel.text = address
                       }
                    }
                }
            } else {
                addressLabel.text = address
            }
        }
        
        self.tableView.reloadData()
       
        
        exportButton.setImage(#imageLiteral(resourceName: "export").resizeImage(CGSize(width: 20.0, height: 20.0)).withRenderingMode(.alwaysOriginal), for: .normal)
        phoneButton.setImage(#imageLiteral(resourceName: "yelpPhone").resizeImage(CGSize(width: 20.0, height: 20.0)).withRenderingMode(.alwaysOriginal), for: .normal)
        websiteButton.setImage(#imageLiteral(resourceName: "website").resizeImage(CGSize(width: 20.0, height: 20.0)).withRenderingMode(.alwaysOriginal), for: .normal)
        
        if doesBusinessExistInBusinessFavoriteList(){
            favoriteButton.setImage(#imageLiteral(resourceName: "checkmark").resizeImage(CGSize(width: 20.0, height: 20.0)).withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            favoriteButton.setImage(nil, for: .normal)
        }
    }
    
    func constructHoursString(weekDayHours: [String: AnyObject]?) -> String{
        
        var hourString: String? = ""
        guard let weekDayHours = weekDayHours else {
            hourString = "Closed"
            return hourString!
        }
        
        if let startTime = weekDayHours["start"], let endTime = weekDayHours["end"]{
            print("*** Start time is \(startTime)")
            print("*** End time is \(endTime)")
            
            if let startTimeString = startTime as? String, let endTimeString = endTime as? String{
                if startTimeString == "0000" && endTimeString == "0000"{
                    return "24 Hours"
                }
            }
            
            if let  startTimeString = startTime as? String{
                let startTimeStringArray = Array(startTimeString.characters)
                let startTimeInt = Int(startTimeString)
                let hour = String(startTimeStringArray[0]).appending(String(startTimeStringArray[1]))
                let minute = String(startTimeStringArray[2]).appending(String(startTimeStringArray[3]))
                
                if startTimeInt! < 1200 {
                    hourString = hour.appending(":").appending(minute).appending(" AM")
                } else {
                    var hourInt = Int(hour)
                    hourInt = 12 - (24 - hourInt!)
                    hourString = String(describing: hourInt!).appending(":").appending(minute).appending(" PM")
                }
                
            }
            
            if let endTimeString = endTime as? String{
                let endTimeStringArray = Array(endTimeString.characters)
                let endTimeInt = Int(endTimeString)
                let hour = String(endTimeStringArray[0]).appending(String(endTimeStringArray[1]))
                let minute = String(endTimeStringArray[2]).appending(String(endTimeStringArray[3]))
                
                if endTimeInt! < 1200 {
                    hourString = hourString!.appending(" - ").appending(hour).appending(":").appending(minute).appending(" AM")
                } else {
                    var hourInt = Int(hour)
                    hourInt = 12 - (24 - hourInt!)
                    hourString = hourString!.appending(" - ").appending(String(describing: hourInt!)).appending(":").appending(minute).appending(" PM")
                }
            }
        }
        
        
        return hourString!
    }
    
    @IBAction func openYelpWebPage(_ sender: UIButton){
        if let urlString = business.url{
            guard let url = URL(string: urlString) else {return}
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func getEstimatedTravelTime(with userLocation: CLLocation){ //Must check if business coordinate is not nil before calling this function!
        guard let _ = business.latitude, let _ = business.longitude else {return}
        let directionsRequest = MKDirectionsRequest()
        let startPlacemartk = MKPlacemark(coordinate: userLocation.coordinate)
        let destinationPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: business.latitude!, longitude: business.longitude!))
        directionsRequest.source = MKMapItem(placemark: startPlacemartk)
        directionsRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directions = MKDirections(request: directionsRequest)
        directions.calculateETA{estimatedTravelTimeResponse, error in
            if error == nil{
                if let estimatedTravelTimeResponse = estimatedTravelTimeResponse{
                    let estimatedTimeInHours = (round(((estimatedTravelTimeResponse.expectedTravelTime / 60) / 60) * 10)) / 10
                    let estimatedTravelTimeInt = Int(estimatedTimeInHours)
                    
                    if estimatedTravelTimeInt == 0 { // travel time less than an hour.
                        
                        let expectedTravelTimeString = String(describing: Int(round(estimatedTravelTimeResponse.expectedTravelTime / 60)))
                        let buttonTitle = "Directions (\(expectedTravelTimeString) min drive)"
                        let buttonTitleNSString = NSString(string: buttonTitle)
                        let buttonTitleDirectionsRange = buttonTitleNSString.range(of: "Directions")
                        let buttonTitleTravelTimeRange = buttonTitleNSString.range(of: "(\(expectedTravelTimeString) min drive)")
                        let mutableAttributedTitleString = NSMutableAttributedString(string: buttonTitle)
                        mutableAttributedTitleString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: 15), range: buttonTitleDirectionsRange)
                        mutableAttributedTitleString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 13), range: buttonTitleTravelTimeRange)
                        self.directionsButton.setAttributedTitle(mutableAttributedTitleString, for: UIControlState.normal)
                    } else { // travel time more than one hour driving.
                        
                        let hourMultiplier = estimatedTravelTimeInt
                        let minuteMultiplier = estimatedTimeInHours - Double(hourMultiplier)
                        print("*** Hour multilier is: \(hourMultiplier)")
                        print("*** Minute multiplier is: \(minuteMultiplier)")
                        
                        var estimatedTravelTimeString = ""
                        
                        if hourMultiplier == 1 {
                            estimatedTravelTimeString = "(\(hourMultiplier) hour"
                        } else if hourMultiplier == 0 {
                            
                        } else {
                            estimatedTravelTimeString = "(\(hourMultiplier) hours"
                        }
                        
                        if minuteMultiplier == 0 {
                            estimatedTravelTimeString = estimatedTravelTimeString + " drive)"
                        } else {
                            estimatedTravelTimeString = estimatedTravelTimeString + " and \(Int(60 * minuteMultiplier)) min drive)"
                        }
                        
                        let buttonTitle = "Directions \(estimatedTravelTimeString)"
                        let buttonTitleNSString = NSString(string: buttonTitle)
                        let buttonTitleDirectionsRange = buttonTitleNSString.range(of: "Directions")
                        let buttonTitleTravelTimeRange = buttonTitleNSString.range(of: estimatedTravelTimeString)
                        let mutableAttributedTitleString = NSMutableAttributedString(string: buttonTitle)
                        mutableAttributedTitleString.addAttribute(NSFontAttributeName, value: UIFont.boldSystemFont(ofSize: 15), range: buttonTitleDirectionsRange)
                        mutableAttributedTitleString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 13), range: buttonTitleTravelTimeRange)
                        self.directionsButton.setAttributedTitle(mutableAttributedTitleString, for: UIControlState.normal)
                    }
                    
                    print("*** Estimated travel time in hours is: \(estimatedTimeInHours)")
                    print("*** Estimated travel time Int is: \(estimatedTravelTimeInt)")
                    
                    
                    
                    self.directionsButton.titleLabel?.numberOfLines = 2
                    self.directionsButton.titleLabel?.textAlignment = .center
                    self.directionsButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
                    self.directionsButton.setNeedsLayout()
                    
                }
            }
        }
    }
    
    @IBAction func navigateToBusiness(){
        
        if let latitude = business.latitude, let longitude = business.longitude{
            let businessCLLocation = CLLocation(latitude: latitude, longitude: longitude)
            geocoder.reverseGeocodeLocation(businessCLLocation){ placemarkArray, error in
                if error == nil {
                    if let placemark = placemarkArray?.first{
                        
                        let cnPostalAddress = CNPostalAddress()
                        
                        
                        var subThoroughFare: String {
                            if let subThoroughFare = placemark.subThoroughfare{
                                return subThoroughFare
                            } else {return ""}
                        }
                        
                        var thoroughFare: String{
                            if let thoroughFare = placemark.thoroughfare{
                                return thoroughFare
                            } else {return ""}
                        }
                        
                        var city: String {
                            if let city = placemark.locality{
                                return city
                            } else {return ""}
                        }
                        
                        var postalCode: String{
                            if let postalCode = placemark.postalCode{
                                return postalCode
                            } else {
                                return ""
                            }
                        }
                        
                        var state: String {
                            if let state = placemark.administrativeArea{
                                return state
                            } else {
                                return ""
                            }
                        }
                        
                        let addressDictionary = [CNPostalAddressStreetKey: "\(subThoroughFare), \(thoroughFare)", CNPostalAddressCityKey: city, CNPostalAddressStateKey: state, CNPostalAddressPostalCodeKey: postalCode]
                        let businessCoordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
                        let businessPlacemark = MKPlacemark(coordinate: businessCoordinate, addressDictionary: addressDictionary)
                        let mapItem = MKMapItem(placemark: businessPlacemark)
                        if let businessName = self.business.name{
                            mapItem.name = businessName
                        }
                        mapItem.openInMaps(launchOptions: [MKLaunchOptionsShowsTrafficKey: "1"])
                    } else {
                        let directionNotAvailableAlert = UIAlertController(title: "Limited Service", message: "Directions currently not available", preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                        directionNotAvailableAlert.addAction(alertAction)
                        self.present(directionNotAvailableAlert, animated: true, completion: nil)
                    }
                } else {
                    
                    let directionNotAvailableAlert = UIAlertController(title: "Limited Service", message: "Directions currently not available", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
                    directionNotAvailableAlert.addAction(alertAction)
                    self.present(directionNotAvailableAlert, animated: true, completion: nil)
                }
            }
           
        } else {
            let directionNotAvailableAlert = UIAlertController(title: "Limited Service", message: "Directions currently not available", preferredStyle: .alert)
            let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            directionNotAvailableAlert.addAction(alertAction)
            present(directionNotAvailableAlert, animated: true, completion: nil)
        }
    }
    
    func addToFavorite(){
        
        
        var businessID: String {
            if let id = business.id{
                return id
            } else {
                return ""
            }
        }
        
        var businessName: String {
            if let name = business.name{
                return name
            } else {
                return ""
            }
        }
        
        var rating: Double{
            if let rating = business.rating{
                return rating
            } else {
                return 0.0
            }
        }
        
        var reviewCount: UInt{
            if let reviewCount = business.review_count{
                return UInt(reviewCount)
            } else {
                return 0
            }
        }
        
        var category: String{
            guard let categories = business.categories else { return ""}
            if let name = categories["name"]{
                return name
            } else {
                return ""
            }
        }
        
        var businessAddress: String{
            if let address = business.address{
                return address
            } else {
                return ""
            }
        }
        
        
        
        
        
        
        
        let  favoriteBusiness: HistoryYelpBusiness = HistoryYelpBusiness(businessIdentifier: businessID, name: businessName, rating: rating, reviewCount: reviewCount, category: category, businessAddress: businessAddress, latitude: business.latitude, longitude: business.longitude)
        
        favoriteBusinesses.append(favoriteBusiness)
        
        self.saveFavoriteBusinessesList()
        
    
        
    }
    
    func doesBusinessExistInBusinessFavoriteList() -> Bool {
        for element in favoriteBusinesses{
            if element.businessIdentifier == business.id{
                return true
            }
        }
        
        return false
    }
    
    func removeBusinessFromFavoriteList(){
        for (index, element) in favoriteBusinesses.enumerated(){
            if element.businessIdentifier == business.id{
                favoriteBusinesses.remove(at: index)
            }
        }
        saveFavoriteBusinessesList()
        print("*** Favorite list count is: \(favoriteBusinesses.count)")
    }
    
    func saveFavoriteBusinessesList(){
        
        guard let documentsDirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let businessFavoriteListPath = documentsDirURL.appendingPathComponent(KeyedArchiverKeys.favoriteBusinessesListKey).path
        
        if NSKeyedArchiver.archiveRootObject(favoriteBusinesses, toFile: businessFavoriteListPath){
            print("*** Archived favorite business list!")
            print("*** Favorite list couns is: \(favoriteBusinesses.count)")
        } else {
            print("*** Failed at archiving favorite business list!")
        }
        
        loadFavoriteBusinessesList()
    }
    
    func loadFavoriteBusinessesList(){
        guard let documentsDirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return
        }
        
        let favoriteBusinessesListPath = documentsDirURL.appendingPathComponent(KeyedArchiverKeys.favoriteBusinessesListKey).path
        
        guard FileManager.default.fileExists(atPath: favoriteBusinessesListPath) else {return}
        
        favoriteBusinesses = NSKeyedUnarchiver.unarchiveObject(withFile: favoriteBusinessesListPath) as! [HistoryYelpBusiness]
    }
}

extension BusinessDetailChildTableViewController: BusinessDetailViewControllerDelegate{
    func businessDetailDidRequestUpdate(_ businessDetail: BusinessDetailViewController, business: Business) {
        self.business = business
        updateTableView(with: business)
        loadYelpComments()
    }
    
    func businessDetailViewControllerDidTapCloseButton(_ businessDetail: BusinessDetailViewController) {
        
    }
    
    func businessDetailViewControllerDidUpdateUserLocation(_ businessDetail: BusinessDetailViewController, newUserLocation: CLLocation) {
        
        if let _ = business.latitude, let _ = business.longitude{
            getEstimatedTravelTime(with: newUserLocation)
        }
    }
}

extension BusinessDetailChildTableViewController{
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let cell = tableView.cellForRow(at: indexPath)
        
        if cell?.reuseIdentifier == BusinessDetailChildTableViewControllerCellIdentifiers.phoneCell{
            if let phoneNumber = business.phone, let phoneURL = URL(string: "tel://" + phoneNumber){
                UIApplication.shared.open(phoneURL)
            }
            return indexPath
        } else if cell?.reuseIdentifier == BusinessDetailChildTableViewControllerCellIdentifiers.addressCell{
            
            var addressString = ""
            if let address = addressLabel.text{
                addressString = address
            }
            activityViewController = UIActivityViewController(activityItems: [addressString], applicationActivities: nil)
            
            if !activityViewController.isBeingPresented{
                present(activityViewController, animated: true, completion: nil)
            }
            
            return indexPath
        } else if cell?.reuseIdentifier == CustomCellTypeIdentifiers.YelpCommentCell{
            if indexPath.row < comments.count {
                if let commentURLString = comments[indexPath.row].commentPageURL{
                    if let commentURL = URL(string: commentURLString){
                        UIApplication.shared.open(commentURL, options: [:], completionHandler: nil)
                    }
                }
            }
            
            return indexPath
        } else if cell?.reuseIdentifier == BusinessDetailChildTableViewControllerCellIdentifiers.yelpWebPageCell{
            if let urlString = business.url{
                guard let url = URL(string: urlString) else {return nil}
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                return indexPath
            }
        } else if cell?.reuseIdentifier == BusinessDetailChildTableViewControllerCellIdentifiers.addToFavoritesCell{
            if doesBusinessExistInBusinessFavoriteList() {
                removeBusinessFromFavoriteList()
                favoriteButton.setImage(nil, for: .normal)
            } else {
                addToFavorite()
                favoriteButton.setImage(#imageLiteral(resourceName: "checkmark").resizeImage(CGSize(width: 20.0, height: 20.0)).withRenderingMode(.alwaysOriginal), for: .normal)
            }
            
            tableView.reloadData()
        }
        
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath){
        if indexPath == IndexPath(row: 0, section: 0){
            cell.separatorInset = UIEdgeInsets(top: 0, left: self.view.bounds.width, bottom: 0, right: 0)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            cell.backgroundColor = UIColor.clear
            
            if cell.reuseIdentifier == "addToFavoritesCell"{
                for favorite in favoriteBusinesses{
                    if let business = business, let id = business.id{
                        if id == favorite.businessIdentifier{
                            favoriteButton.setImage(#imageLiteral(resourceName: "checkmark").resizeImage(CGSize(width: 20.0, height: 20.0)).withRenderingMode(.alwaysOriginal), for: .normal)
                        }
                    }
                }
                
            }
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.YelpCommentCell) as! YelpCommentCell
            cell.backgroundColor = UIColor.clear
            if indexPath.row < comments.count{ // Checking if number of static cells are in synic with number of comments in comments array
                cell.configureCell(with: comments[indexPath.row])
            }
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 1{
            return 20
        } else {return 0}
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 1{
            if let sectionOneHeaderViewContainer = sectionOneHeaderViewContainer{
                return sectionOneHeaderViewContainer.bounds.height
            } else {return 0.0}
        } else {
            return 0.0
        }
    }
    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let _ = business else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
        
        if indexPath.section == 0 {
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            if business.photos == nil && cell.reuseIdentifier == BusinessDetailChildTableViewControllerCellIdentifiers.imagesCell{
                return 0
            }
            
            if business.display_phone == nil && cell.reuseIdentifier == BusinessDetailChildTableViewControllerCellIdentifiers.phoneCell{
                return 0
            }
            
            if business.display_address == nil && business.latitude == nil && business.longitude == nil && cell.reuseIdentifier == BusinessDetailChildTableViewControllerCellIdentifiers.addressCell{
                return 0
            }
            
            if business.hours == nil && cell.reuseIdentifier == BusinessDetailChildTableViewControllerCellIdentifiers.hoursCell{
                hoursStackView.isHidden = true
                weekDaysStackView.isHidden = true
                businessHoursNotAvailableLabel.isHidden = false
                return 44
            }
        } else {
            
            if indexPath.row < comments.count{ // Checking if number of static cells are in synic with number of comments in comments array. If the comment cell is empty we hide it by reducing its height to zero.
                return 111
            } else {
                return 0
            }
        }
        
        
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 1{
            if let sectionOneHeaderViewContainer = sectionOneHeaderViewContainer{
                return sectionOneHeaderViewContainer
            } else {
                return nil
            }
        } else {return nil}
    }

    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let sectionOneRows = tableView.numberOfRows(inSection: 1)
        if indexPath.row == sectionOneRows - 1 && indexPath.section == 1{ //Determine if the table view has finished loading.
            tableView.reloadData()
        }
    }
}




