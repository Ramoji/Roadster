
import UIKit
import YelpAPI
import Alamofire
import SwiftyJSON
import CoreLocation


class MulticastDelegate<T>{
    private var delegates: [T] = []
    
    func add(delegate: T){
        delegates.append(delegate)
    }
    
    func invokeDelegates(invocation: (T) -> ()){
        for delegate in delegates{
            invocation(delegate)
        }
    }
}


protocol BusinessDetailViewControllerDelegate: class {
    func businessDetailDidRequestUpdate(_ businessDetail: BusinessDetailViewController, business: Business)
    func businessDetailViewControllerDidTapCloseButton(_ businessDetail: BusinessDetailViewController)
    func businessDetailViewControllerDidUpdateUserLocation(_ businessDetail: BusinessDetailViewController, newUserLocation: CLLocation)
}

struct Business {
    let id: String?
    let name: String?
    let image_url: String?
    let is_claimed: Bool?
    let is_closed: Bool?
    let url: String?
    let phone: String?
    let display_phone: String?
    let review_count: Int?
    let categories: [String: String]?
    let rating: Double?
    let address: String?
    let city: String?
    let zip_code: String?
    let country: String?
    let state: String?
    let display_address: String?
    let cross_streets: String?
    let latitude: Double?
    let longitude: Double?
    let photos: [String]?
    let price: String?
    let hours: Hours?
    let hours_type: String?
    let is_open_now: Bool?
    let transactions: [String]?

}

struct Hours {
    let monday: [String: AnyObject]?
    let tuesday: [String: AnyObject]?
    let wednesday: [String: AnyObject]?
    let thursday: [String: AnyObject]?
    let friday: [String: AnyObject]?
    let saturday: [String: AnyObject]?
    let sunday: [String: AnyObject]?
}

class BusinessDetailViewController: UIViewController{
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var businessTitleLabel: UILabel!
    @IBOutlet weak var catergoryLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    var businessID: String?
    var businessDetailChildTableViewController: BusinessDetailChildTableViewController!
    var delegates = MulticastDelegate<BusinessDetailViewControllerDelegate>()
    var business: Business?
    var currentUserLocation: CLLocation!
    @IBOutlet weak var ratingImageView: UIImageView!
    var locationManager: CLLocationManager!
    

    override func viewDidLoad() {
        super.viewDidLoad()
    
        constraintContainerView()
        setUpView()
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        getBusinessFromYelpAPI()
        setUpLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let blurView = BlurredBackgroundView(frame: self.view.bounds, addBackgroundPic: true)
        blurView.layer.masksToBounds = true
        blurView.layer.cornerRadius = 15.0
        view.addSubview(blurView)
        view.sendSubview(toBack: blurView)
    }
    
    func configureBusinessDetailViewController(){
    }
    
    func getBusinessFromYelpAPI(){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        
    
        if let dateString = UserDefaults.standard.string(forKey: DefaultKeys.yelpAccessTokenExpiryDate) {
            
            let tokenExpiryDate = dateFormatter.date(from: dateString)!
            
            if tokenExpiryDate.timeIntervalSinceNow < -15552000{
                
                let parameters: Parameters = ["grant_type": "client_credentials", "client_id": APICredentials.yelpAPI_ID, "client_secret": APICredentials.yelpAPI_secret]
                
                Alamofire.request("https://api.yelp.com/oauth2/token", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON{ response in
                    
                    
                    do{
                        let jsonObj = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as! [String: AnyObject]
                        UserDefaults.standard.set(jsonObj["access_token"] as! String, forKey: DefaultKeys.yelpAccessToken)
                        UserDefaults.standard.set(dateFormatter.string(from: Date()), forKey: DefaultKeys.yelpAccessTokenExpiryDate)
                    } catch let error as NSError{
                        print(error.debugDescription)
                        print(error.localizedDescription)
                    }
                    
                    
                    let businessURL = "https://api.yelp.com/v3/businesses/" + self.businessID!
                    let headers: HTTPHeaders = ["Authorization": "Bearer \(UserDefaults.standard.object(forKey: DefaultKeys.yelpAccessToken)!)"]
                    Alamofire.request(businessURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{response in
                        if response.response?.statusCode == 200{
                            self.business = self.parse(businessDicData: response.data!)
                            self.setUpBusinessTitle()
                            self.delegates.invokeDelegates{
                                $0.businessDetailDidRequestUpdate(self, business: self.business!)
                            }
                        }
                    }
                }
                
            } else {
                
                let businessURL = "https://api.yelp.com/v3/businesses/" + self.businessID!
                let headers: HTTPHeaders = ["Authorization": "Bearer \(UserDefaults.standard.object(forKey: DefaultKeys.yelpAccessToken)!)"]
                Alamofire.request(businessURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{response in
                    print(response)
                    if response.response?.statusCode == 200{
                        self.business = self.parse(businessDicData: response.data!)
                        self.setUpBusinessTitle()
                        self.delegates.invokeDelegates{
                            $0.businessDetailDidRequestUpdate(self, business: self.business!)
                        }
                    }
                }
            }
            
            
        } else {
            
            let parameters: Parameters = ["grant_type": "client_credentials", "client_id": APICredentials.yelpAPI_ID, "client_secret": APICredentials.yelpAPI_secret]
            
            Alamofire.request("https://api.yelp.com/oauth2/token", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON{ response in
                
                
                do{
                    let jsonObj = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as! [String: AnyObject]
                    UserDefaults.standard.set(jsonObj["access_token"] as! String, forKey: DefaultKeys.yelpAccessToken)
                    UserDefaults.standard.set(dateFormatter.string(from: Date()), forKey: DefaultKeys.yelpAccessTokenExpiryDate)
                } catch let error as NSError{
                    print(error.debugDescription)
                    print(error.localizedDescription)
                }
                
                
                let businessURL = "https://api.yelp.com/v3/businesses/" + self.businessID!
                let headers: HTTPHeaders = ["Authorization": "Bearer \(UserDefaults.standard.object(forKey: DefaultKeys.yelpAccessToken)!)"]
                Alamofire.request(businessURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{response in
                    if response.response?.statusCode == 200{
                        self.business = self.parse(businessDicData: response.data!)
                        self.setUpBusinessTitle()
                        self.delegates.invokeDelegates{
                            $0.businessDetailDidRequestUpdate(self, business: self.business!)
                        }
                    }
                }
            }
        }
    }

   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func parse(businessDicData: Data) -> Business{
        
        let json = JSON(data: businessDicData)
        
        let id: String! = json["id"].stringValue
        let name: String! = json["name"].stringValue
        let image_url: String! = json["image_url"].stringValue
        let is_claimed: Bool! = json["is_claimed"].boolValue
        let is_closed: Bool! = json["is_closed"].boolValue
        let url: String! = json["url"].stringValue
        let phone: String! = json["phone"].stringValue
        let display_phone: String! = json["display_phone"].stringValue
        let review_count: Int! = json["review_count"].intValue
        
        let categoriesAliasPath: [JSONSubscriptType] = ["categories", 0, "alias"]
        let categoriesTitlePath: [JSONSubscriptType] = ["categories", 0, "title"]
        let categories: [String: String]! = ["alias": json[categoriesAliasPath].stringValue, "title": json[categoriesTitlePath].stringValue]
        
        let rating: Double? = json["rating"].doubleValue
        
        let address1Path: [JSONSubscriptType] = ["location", "address1"]
        let address: String? = json[address1Path].stringValue
        
        let cityPath: [JSONSubscriptType] = ["location", "city"]
        let city: String? = json[cityPath].stringValue
        
        let zip_codePath: [JSONSubscriptType] = ["location", "zip_code"]
        let zip_code: String? = json[zip_codePath].stringValue
        
        let countryPath: [JSONSubscriptType] = ["location", "country"]
        let country: String? = json[countryPath].stringValue
        
        let statePath: [JSONSubscriptType] = ["location", "state"]
        let state: String? = json[statePath].stringValue
        
        let display_addressPath1: [JSONSubscriptType] = ["location", "display_address", 0]
        let display_addressPath2: [JSONSubscriptType] = ["location", "display_address", 1]
        let display_address: String? = json[display_addressPath1].stringValue.appending(", ").appending(json[display_addressPath2].stringValue)
        
        let cross_streetPath: [JSONSubscriptType] = ["location", "cross_streets"]
        let cross_streets: String? = json[cross_streetPath].stringValue
        
        let latitudePath: [JSONSubscriptType] = ["coordinates", "latitude"]
        let longitudePath: [JSONSubscriptType] = ["coordinates", "longitude"]
        let latitude: Double? = json[latitudePath].doubleValue
        let longitude: Double? = json[longitudePath].doubleValue
        
        let photos: [String]? = json["photos"].arrayValue.map({$0.stringValue})
        let price: String? = json["price"].stringValue
        
        let hours_typePath: [JSONSubscriptType] = ["hours", 0, "hours_type"]
        let openHoursPath: [JSONSubscriptType] = ["hours", 0, "open"]
        let openHoursArray = json[openHoursPath].arrayValue.map({$0.dictionaryValue})
        let is_open_nowPath: [JSONSubscriptType] = ["hours", 0, "is_open_now"]
        var weeklyOpenHoursArray: [[String: AnyObject]] = []
        for openHours in openHoursArray{
            let openHourDictionary: [String: AnyObject] = ["is_overnight": openHours["is_overnight"]?.boolValue as AnyObject,
                                                           "end": openHours["end"]?.stringValue as AnyObject,
                                                           "day": openHours["day"]?.intValue as AnyObject,
                                                           "start": openHours["start"]?.stringValue as AnyObject]
            weeklyOpenHoursArray.append(openHourDictionary)
        }
        var hours: Hours!
        if !weeklyOpenHoursArray.isEmpty{
            
            var monday: [String: AnyObject]?
            var tuesday: [String: AnyObject]?
            var wednesday: [String: AnyObject]?
            var thursday: [String: AnyObject]?
            var friday: [String: AnyObject]?
            var saturday: [String: AnyObject]?
            var sunday: [String: AnyObject]?
            
            
            
            for (index, openHours) in weeklyOpenHoursArray.enumerated(){
                
                if index < weeklyOpenHoursArray.count{
                    if index == 0 {
                        monday = openHours
                    } else if index == 1 {
                        tuesday = openHours
                    } else if index == 2 {
                        wednesday = openHours
                    } else if index == 3 {
                        thursday = openHours
                    } else if index == 4 {
                        friday = openHours
                    } else if index == 5 {
                        saturday = openHours
                    } else if index == 6 {
                        sunday = openHours
                    }
                }
                
            }
                hours = Hours(monday: monday, tuesday: tuesday, wednesday: wednesday, thursday: thursday, friday: friday, saturday: saturday, sunday: sunday)
        }
    
        let hours_type: String? = json[hours_typePath].stringValue
        let is_open_now: Bool? = json[is_open_nowPath].boolValue
        
        
        let transactions: [String]? = json["transactions"].arrayValue.map({$0.stringValue})
        
        let business = Business(id: id,
                                name: name,
                                image_url: image_url,
                                is_claimed: is_claimed,
                                is_closed: is_closed,
                                url: url,
                                phone: phone,
                                display_phone: display_phone,
                                review_count: review_count,
                                categories: categories,
                                rating: rating,
                                address: address,
                                city: city,
                                zip_code: zip_code,
                                country: country,
                                state: state,
                                display_address: display_address,
                                cross_streets: cross_streets,
                                latitude: latitude,
                                longitude: longitude,
                                photos: photos,
                                price: price,
                                hours: hours,
                                hours_type: hours_type,
                                is_open_now: is_open_now,
                                transactions: transactions)
        return business
    }
    

    
    func constraintContainerView(){
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        let topConstraint = containerView.topAnchor.constraint(equalTo: ratingLabel.bottomAnchor, constant: 5.0)
        let leadingConstraint = containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        let widthConstraint = containerView.widthAnchor.constraint(equalToConstant: self.view.bounds.width)
        let heightConstraint = containerView.heightAnchor.constraint(equalToConstant: 405.0)
        NSLayoutConstraint.activate([topConstraint, leadingConstraint, widthConstraint, heightConstraint])
        
    }
    
    func setUpView(){
        view.addShadow(withCornerRadius: 15.0)
        view.layer.cornerRadius = 15
        
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        constraintContainerView()
        setUpView()
    }
    
    
    
    @IBAction func close(_ sender: UIButton){
        print("*** In close method to remove BusinessDetailViewController!")
        delegates.invokeDelegates{
            $0.businessDetailViewControllerDidTapCloseButton(self)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "businessDetailChildTableViewController"{
            businessDetailChildTableViewController = segue.destination as! BusinessDetailChildTableViewController
            if let business = business{
                businessDetailChildTableViewController.business = business
            }
            self.delegates.add(delegate: businessDetailChildTableViewController)
        }
    }
    
    func setUpBusinessTitle(){
        
        ratingImageView.image = #imageLiteral(resourceName: "0stars").resizeImage(CGSize(width: 90.0, height: 17.0))
        
       
        
        if let business = business{
            if let name  = business.name{businessTitleLabel.text = name}
            
            
            if let reviewCount = business.review_count, let price = business.price, let rating = business.rating{
                let ratingString = "(\(reviewCount)) on Yelp · \(price)"
                ratingLabel.text = ratingString
                if let ratingImage = UIImage(named: "\(rating)stars"){
                    ratingImageView.image = ratingImage.resizeImage(CGSize(width: 90.0, height: 17.0))
                }
            }
            
            var catergoryString: String = ""
            
            if let category = business.categories?["title"]!{
                catergoryString = category
            }
            
            if let isOpenNow = business.is_open_now{
        
                if isOpenNow{
                    catergoryString.append(" · Closed Now")
                    let nsString = catergoryString as NSString
                    let closedNowRange: NSRange = nsString.range(of: "Closed Now")
                    print(closedNowRange.length)
                    let mutableAttributedDistanceString = NSMutableAttributedString(string: catergoryString)
                    mutableAttributedDistanceString.addAttributes([NSForegroundColorAttributeName: UIColor.red], range: closedNowRange)
                    
                    catergoryLabel.attributedText = mutableAttributedDistanceString
                } else {
                    catergoryLabel.text = catergoryString
                }
                
            }
            
            startLocationManager()
            
        }
        
        view.setNeedsLayout()
    }
    
    func addDistanceToCategoryLabel(){
        
        if let latitude = business?.latitude, let longitude = business?.longitude{
            let businessLocation = CLLocation(latitude: latitude, longitude: longitude)
            let businessDistanceFromUser = String(round(10 * (businessLocation.distance(from: currentUserLocation) / 1609.34)) / 10)
            
            let category = business?.categories?["title"]!
            
            var categoryString: String  = ""
            categoryString = (category?.appending(" · \(businessDistanceFromUser) mi"))!
            
            if let isOpenNow = business?.is_open_now{
                if isOpenNow{
                    catergoryLabel.text = categoryString
                } else {
                    categoryString = categoryString.appending(" · Closed Now")
                    let categoryNSString = categoryString as NSString
                    let closedNowRange = categoryNSString.range(of: "Closed Now")
                    let categoryNSMutableAttributedString = NSMutableAttributedString(string: categoryString)
                    categoryNSMutableAttributedString.addAttributes([NSForegroundColorAttributeName: UIColor.red], range: closedNowRange)
                    catergoryLabel.attributedText = categoryNSMutableAttributedString
                }
            } else {
                catergoryLabel.text = categoryString
            }
        }
        
        //let businessDistanceFromU
    }
    
    func setUpLocationManager(){
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.allowsBackgroundLocationUpdates = false
        if CLLocationManager.authorizationStatus() == .notDetermined || CLLocationManager.authorizationStatus() == .denied{
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func startLocationManager(){
        if let locationManager = locationManager{
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
    }
    
    func stopLocationManager(){
        if let locationManager = locationManager{
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
        }
    }

    deinit {
        print("*** BusinessDetailViewController instance was terminated.")
    }
}

extension BusinessDetailViewController: CLLocationManagerDelegate{
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("In location manager.")
        let newLocation = locations.last!
        print(newLocation.horizontalAccuracy)
        if newLocation.horizontalAccuracy < 0 {
            return
        }
    
        if newLocation.timestamp.timeIntervalSinceNow < -5 {return}
        
        if newLocation.horizontalAccuracy <= locationManager.desiredAccuracy{
            currentUserLocation = newLocation
            stopLocationManager()
            addDistanceToCategoryLabel()
            delegates.invokeDelegates{
                $0.businessDetailViewControllerDidUpdateUserLocation(self, newUserLocation: currentUserLocation)
            }
        }
    }
}
