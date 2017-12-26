

import UIKit
import MapKit
import CoreLocation

class StaticDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var parkingImageView: UIImageView!
    @IBOutlet weak var imageViewOne: UIImageView!
    @IBOutlet weak var imageViewTwo: UIImageView!
    @IBOutlet weak var imageViewThree: UIImageView!
    @IBOutlet weak var imageViewFour: UIImageView!
    @IBOutlet weak var imageViewFive: UIImageView!
    @IBOutlet weak var imageViewSix: UIImageView!
    @IBOutlet weak var imageViewSeven: UIImageView!
    @IBOutlet weak var imageViewEight: UIImageView!
    @IBOutlet weak var imageViewNine: UIImageView!
    @IBOutlet weak var imageViewTen: UIImageView!
    var imageViews: [UIImageView]!
    
    @IBOutlet weak var facilitiesLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var truck: UIImageView!
    @IBOutlet weak var sedanCar: UIImageView!
    @IBOutlet weak var trailer: UIImageView!
    
    
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commnetButton: UIButton!
    @IBOutlet weak var cancelComment: UIButton!
    @IBOutlet weak var commentRatingImageView: UIImageView!
    @IBOutlet weak var ratingImageView: UIImageView!
    
    @IBOutlet weak var commentTextViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var favoriteButton: UIButton!
    @IBOutlet weak var reportInfoButton: UIButton!
    @IBOutlet weak var navigateButton: UIButton!
    @IBOutlet weak var frequentButton: UIButton!
    
    var sectionOneHeaderViewContainerView: UIView!
    
    
    
    
    
    var restStop: USRestStop!
    var fullStateName: String!
    let blurredBackgroudView = BlurredBackgroundView(frame: CGRect.zero, addBackgroundPic: true)
    var comments: [Comment] = []
    var averageRating: Double = 0.0
    var commentRating: Double = 0
    var favoriteList: [Favorite] = []
    var frequentList: [Frequent] = []
    
    

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        sectionOneHeaderViewContainerView = getSectionOneHeaderView()
        setUpSegmentedControl()
        navigationItem.title = restStop.mileMarker
        setUpViewForRestStop()
        loadComments()
        
        ratingImageView.contentMode = .scaleAspectFit
        commentRatingImageView.isUserInteractionEnabled = true
        ///////////
        let nib = UINib(nibName: "CommentCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CommentCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 70
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if commentTextView.isFirstResponder{
            commentTextView.resignFirstResponder()
            hideCommentButtons()
        }
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor.clear
        tableView.backgroundView = blurredBackgroudView
        setUpTableView()
        loadFavoriteList()
        loadFrequentList()
    }
    
    override func loadView() {
        super.loadView()
        imageViews = [imageViewOne, imageViewTwo, imageViewThree, imageViewFour, imageViewFive, imageViewSix, imageViewSeven, imageViewEight, imageViewNine, imageViewTen]
    }
    
    func setUpTableView(){
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 88
    }
    
    func setUpSegmentedControl(){
        segmentedControl.addTarget(self, action: #selector(handleSegmentChange), for: UIControlEvents.valueChanged)
    }
    
    func handleSegmentChange(){
        if segmentedControl.selectedSegmentIndex == 0{
            mapView.mapType = MKMapType.standard
        } else {
            mapView.mapType = MKMapType.hybrid
        }
    }
    
    func setUpViewForRestStop(){
        
        
        let iconSize = CGSize(width: 25.0, height: 25.0)
        
        if let ratingImage = UIImage(named: "\(averageRating)stars"){
            ratingImageView.image = ratingImage.resizeImage(CGSize(width: ratingImageView.bounds.width, height:ratingImageView.bounds.height)).withRenderingMode(.alwaysOriginal)
        }
        
        let vehicleIconSize = CGSize(width: 25.0, height: 25.0)
        prepIconViews()
        if let restStop = restStop, let fullStateName = fullStateName{
            titleLabel.text = "Rest Stop on \((restStop.routeName as NSString)) in \(fullStateName.capitalized)"
            mapView.addAnnotation(restStop)
            latitudeLabel.text =  restStop.latitude.convertToString()
            longitudeLabel.text = restStop.longitude.convertToString()
            parkingImageView.image = UIImage(named: "parking")?.resizeImage(iconSize)
            sedanCar.image = UIImage(named: "sedan")?.resizeImage(iconSize)
            if restStop.rvDump{
                trailer.image = UIImage(named: "rvDump")?.resizeImage(vehicleIconSize)
            }
            if restStop.trucks{
                truck.image = UIImage(named: "truck")?.resizeImage(vehicleIconSize)
            }
            parkingImageView.image = UIImage(named: "parking")?.resizeImage(iconSize)
        }
        setUpMapView()
        configureFacilityIcons()
        
        if restStop.favorite{
            favoriteButton.imageView?.contentMode = .scaleAspectFit
            favoriteButton.setTitle("", for: .normal)
            favoriteButton.setImage(UIImage(named: "favoriteOn")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            
            favoriteButton.imageView?.contentMode = .scaleAspectFit
            favoriteButton.setTitle("", for: .normal)
            favoriteButton.setImage(UIImage(named: "favoriteOff")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        reportInfoButton.imageView?.contentMode = .scaleAspectFit
        reportInfoButton.setTitle("", for: .normal)
        reportInfoButton.setImage(UIImage(named: "reportInfo")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: UIControlState.normal)
        
        navigateButton.imageView?.contentMode = .scaleAspectFit
        navigateButton.setTitle("", for: .normal)
        navigateButton.setImage(UIImage(named: "navigate")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: UIControlState.normal)
        
        if restStop.frequent{
            frequentButton.imageView?.contentMode = .scaleAspectFit
            frequentButton.setTitle("", for: .normal)
            frequentButton.setImage(UIImage(named: "frequentOn")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: .normal)
        } else {
            frequentButton.imageView?.contentMode = .scaleAspectFit
            frequentButton.setTitle("", for: .normal)
            frequentButton.setImage(UIImage(named: "frequentOff")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
        view.setNeedsLayout()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("***Receiving Memory Warning from StaticDetailTableViewController!")
    }

    
    
    func setUpMapView(){
        if let restStop = restStop{
            let region = MKCoordinateRegionMakeWithDistance(restStop.coordinate, 500, 500)
            mapView.setRegion(region, animated: true)
            mapView.isUserInteractionEnabled = false
        }
    }
    
    private func prepIconViews(){
        for imageView in imageViews{
            imageView.isHidden = true
            imageView.image = nil
        }
    }
    
    private func configureFacilityIcons(){
        let facilites = POIProvider.getFacilityList(forRestStop: restStop)
        for (index, facility) in facilites.enumerated(){
            let imageSize = CGSize(width: 20.0, height: 20.0)
            let facilityImageView = imageViews![index]
            facilityImageView.isHidden = false
            facilityImageView.image = UIImage(named: facility)?.resizeImage(imageSize)
        }
    }
    @IBAction func comment(_ sender: UIButton) {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        
        
        let commentText = commentTextView.text!
        
        
        
        let email = UserDefaults.standard.object(forKey: DefaultKeys.currentUserEmail) as! String
        let username = UserDefaults.standard.object(forKey: DefaultKeys.currentUsername) as! String
        let firstname = UserDefaults.standard.object(forKey: DefaultKeys.firstName) as! String
        let lastname = UserDefaults.standard.object(forKey: DefaultKeys.lastName) as! String
        
        let dateString = dateFormatter.string(from: Date())
        
        let comment = Comment(latitude: restStop.coordinate.latitude.convertToString(), longitude: restStop.coordinate.longitude.convertToString(), firstname: firstname, lastname: lastname, email: email, username: username, comment: commentText, date: dateString, rating: commentRating)
        
    
        HTTPHelper.shared.postComment(comment: comment, userEmail: email){
            completed in
            
            if completed{
                self.loadComments()
            } else {
                let couldNotPostCommentAlert = UIAlertController(title: "Network Error", message: "Could not post comment due to a network error. Please try again in a few moments", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                couldNotPostCommentAlert.addAction(action)
                self.present(couldNotPostCommentAlert, animated: true, completion: nil)
            }
        }
        
        
        hideCommentButtons()
    
    }
    
    @IBAction func commentRatingImageViewDidTap(_ sender: UITapGestureRecognizer){
        let tapLocation = sender.location(in: commentRatingImageView)
        if tapLocation.x <= 10{
            commentRatingImageView.image = #imageLiteral(resourceName: "0stars").resizeImage(CGSize(width: commentRatingImageView.bounds.width, height: commentRatingImageView.bounds.height)).withRenderingMode(.alwaysOriginal)
            commentRating = 0
        } else if tapLocation.x > 10 && tapLocation.x <= 20 {
            commentRatingImageView.image = #imageLiteral(resourceName: "1.0stars").resizeImage(CGSize(width: commentRatingImageView.bounds.width, height: commentRatingImageView.bounds.height)).withRenderingMode(.alwaysOriginal)
            commentRating = 1
        } else if tapLocation.x > 20 && tapLocation.x <= 30{
            commentRatingImageView.image = #imageLiteral(resourceName: "1.5stars").resizeImage(CGSize(width: commentRatingImageView.bounds.width, height: commentRatingImageView.bounds.height)).withRenderingMode(.alwaysOriginal)
            commentRating = 1.5
        } else if tapLocation.x > 30 && tapLocation.x <= 40{
            commentRatingImageView.image = #imageLiteral(resourceName: "2.0stars").resizeImage(CGSize(width: commentRatingImageView.bounds.width, height: commentRatingImageView.bounds.height)).withRenderingMode(.alwaysOriginal)
            commentRating = 2.0
        } else if tapLocation.x > 40 && tapLocation.x <= 50{
            commentRatingImageView.image = #imageLiteral(resourceName: "2.5stars").resizeImage(CGSize(width: commentRatingImageView.bounds.width, height: commentRatingImageView.bounds.height)).withRenderingMode(.alwaysOriginal)
            commentRating = 2.5
        } else if tapLocation.x > 50 && tapLocation.x <= 60{
            commentRatingImageView.image = #imageLiteral(resourceName: "3.0stars").resizeImage(CGSize(width: commentRatingImageView.bounds.width, height: commentRatingImageView.bounds.height)).withRenderingMode(.alwaysOriginal)
            commentRating = 3.0
        } else if tapLocation.x > 60 && tapLocation.x <= 70{
            commentRatingImageView.image = #imageLiteral(resourceName: "3.5stars").resizeImage(CGSize(width: commentRatingImageView.bounds.width, height: commentRatingImageView.bounds.height)).withRenderingMode(.alwaysOriginal)
            commentRating = 3.5
        } else if tapLocation.x > 70 && tapLocation.x <= 80{
            commentRatingImageView.image = #imageLiteral(resourceName: "4.0stars").resizeImage(CGSize(width: commentRatingImageView.bounds.width, height: commentRatingImageView.bounds.height)).withRenderingMode(.alwaysOriginal)
            commentRating = 4.0
        } else if tapLocation.x > 80 && tapLocation.x <= 90{
            commentRatingImageView.image = #imageLiteral(resourceName: "4.5stars").resizeImage(CGSize(width: commentRatingImageView.bounds.width, height: commentRatingImageView.bounds.height)).withRenderingMode(.alwaysOriginal)
            commentRating = 4.5
        } else if tapLocation.x > 90 && tapLocation.x <= 100{
            commentRatingImageView.image = #imageLiteral(resourceName: "5.0stars").resizeImage(CGSize(width: commentRatingImageView.bounds.width, height: commentRatingImageView.bounds.height)).withRenderingMode(.alwaysOriginal)
            commentRating = 5.0
        }
    }
    
    @IBAction func cancelComment(_ sender: UIButton) {
        print("*** In cancel button!")
        hideCommentButtons()
    }
    
    
    func hideCommentButtons(){
        //if commentTextView.isFirstResponder{
            resetCommentRatingImageView()
            commentRatingImageView.image = #imageLiteral(resourceName: "0stars").resizeImage(CGSize(width: commentRatingImageView.bounds.width, height: commentRatingImageView.bounds.height)).withRenderingMode(.alwaysOriginal)
            commentTextView.resignFirstResponder()
            commentTextView.textColor = UIColor.lightGray
            commentTextView.text = "Add a public comment..."
            UIView.animate(withDuration: 0.5){
                self.commnetButton.center.y = 50
                self.commnetButton.alpha = 0.0
                self.cancelComment.center.y = 50
                self.cancelComment.alpha = 0.0
                self.commentRatingImageView.center.y = 50
                self.commentRatingImageView.alpha = 0.0
                self.commentTextViewHeightConstraint.constant = 40
                self.view.setNeedsLayout()
                self.commnetButton.isEnabled = false
                self.cancelComment.isEnabled = false
            }
       // }
    }
    
    private func resetCommentRatingImageView(){
        commentRatingImageView.image = #imageLiteral(resourceName: "0stars").resizeImage(CGSize(width: commentRatingImageView.bounds.width, height: commentRatingImageView.bounds.height)).withRenderingMode(.alwaysOriginal)
        commentRating = 0
    }
    
    func loadComments(){
        HTTPHelper.shared.getComments(latitude: restStop.latitude, longitude: restStop.longitude){ publicComments, averageRating in
            self.comments = publicComments
            self.averageRating = averageRating
            self.tableView.reloadData()
            self.setUpViewForRestStop()
        }
    }
    
    @IBAction func saveFavorite(_ sender: UIButton){
        let managedObjectContext = restStop.managedObjectContext!
        if restStop.favorite{
            //change rest stop favotire status and re-save (unfavorite)
            favoriteButton.setImage(UIImage(named: "favoriteOff")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: .normal)
            restStop.favorite = false
            do{
                try managedObjectContext.save()
                print("*** Deleted favorite!")
            }catch{
                fatalError("*** Failed to update rest stop favorite status.")
            }
            //remove favorite from core data
            print("*** latitude: \(restStop.latitude), longitude: \(restStop.longitude)")
            CoreDataHelper.shared.deleteFavorite(latitude: restStop.latitude, longitude: restStop.longitude)
        } else {
            //change rest stop favotire status and re-save (favorite)
            favoriteButton.setImage(UIImage(named: "favoriteOn")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: .normal)
            restStop.favorite = true
            do{
                try managedObjectContext.save()
                print("*** Saved favorite!")
            }catch{
                fatalError("*** Failed to update rest stop favorite status.")
            }
            //save favorite to core data
            CoreDataHelper.shared.saveFavorite(restStop: restStop)
        }
    }
    
    @IBAction func saveFrequent(_ sender: UIButton){
        let managedObjectContext = restStop.managedObjectContext!
        if restStop.frequent{
            //change rest stop frequent status and re-save (unfrequent)
            frequentButton.setImage(UIImage(named: "frequentOff")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: .normal)
            restStop.frequent = false
            do {
                try managedObjectContext.save()
                print("*** Deleted frequent!")
            } catch {
                fatalError("*** Failed to update rest stop frequent status.")
            }
            //remove favorite from core data
            CoreDataHelper.shared.deleteFrequent(latitude: restStop.latitude, longitude: restStop.longitude)
        } else {
            //change rest stop frequent status and re-save (frequent)
            frequentButton.setImage(UIImage(named: "frequentOn")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: .normal)
            restStop.frequent = true
            do {
                try managedObjectContext.save()
                print("*** Saved frequent!")
            } catch {
                fatalError("*** Failed to update rest stop frequent status.")
            }
            //save favorite to core data
            CoreDataHelper.shared.saveFrequent(restStop: restStop)
        }
    }
    
    func loadFavoriteList(){
        
        favoriteList = CoreDataHelper.shared.getFavorites()
        
        for favorite in favoriteList{
            if favorite.latitude == restStop.latitude && favorite.longitude == restStop.longitude{
                favoriteButton.setImage(UIImage(named: "favoriteOn")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: .normal)
                return
            }
        }
        
        favoriteButton.setImage(UIImage(named: "favoriteOff")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: .normal)
    
    }
    
    func loadFrequentList(){
        
        frequentList = CoreDataHelper.shared.getFrequents()
        
        for frequent in frequentList{
            if frequent.latitude == restStop.latitude && frequent.longitude == restStop.longitude{
                frequentButton.setImage(UIImage(named: "frequentOn")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: .normal)
                return
            }
        }
        
        frequentButton.setImage(UIImage(named: "frequentOff")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: .normal)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "reportInfo"{
            let reportInfoTableViewController = segue.destination as! ReportInfoTableViewController
            reportInfoTableViewController.restStop = restStop
        }
    }
    
    @IBAction func navigate(){
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(restStop.latitude, restStop.longitude)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = "Start"
        mapItem.openInMaps(launchOptions: options)
        
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
    
    @IBAction func unwindToStaticDetailTableViewController(_ sender: UIStoryboardSegue){
        
    }
}



extension StaticDetailTableViewController: MKMapViewDelegate{
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let anotationSize = CGSize(width: 30.0, height: 30.0)
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "annotationView")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "annotationView")
            annotationView?.image = UIImage(named: "restStop")?.resizeImage(anotationSize)
        }
        annotationView!.annotation = annotation
        return annotationView
    }
}

extension StaticDetailTableViewController: UITextViewDelegate{
    func textViewDidBeginEditing(_ textView: UITextView) {
        
        guard UserDefaults.standard.bool(forKey: DefaultKeys.signedIn) else {
            let signUpViewController = storyboard?.instantiateViewController(withIdentifier: "SignUpViewController") as! SignUpViewController
            signUpViewController.originalPresenter = self
                present(signUpViewController, animated: true, completion: nil)
            return
        }
        
        
        textView.text = ""
        textView.textColor = UIColor.black
        commnetButton.isHidden = false
        commnetButton.isEnabled = false
        cancelComment.isHidden = false
        cancelComment.isEnabled = true
        commentRatingImageView.isHidden = false
        commentTextView.translatesAutoresizingMaskIntoConstraints = false
        commnetButton.backgroundColor = UIColor(red: 0, green: 122/256, blue: 255/256, alpha: 0.5)
        UIView.animate(withDuration: 0.5){
            self.commnetButton.center.y = 77
            self.commnetButton.alpha = 1.0
            self.cancelComment.center.y = 77
            self.cancelComment.alpha = 1.0
            self.commentTextViewHeightConstraint.constant = 50
            self.commentRatingImageView.center.y = 77
            self.commentRatingImageView.alpha = 1.0
            self.view.setNeedsLayout()
            
        }
        
        
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if textView.text != "" && textView.text != " "{
            
            commnetButton.backgroundColor = UIColor(red: 0, green: 122/256, blue: 255/256, alpha: 1.0)
            commnetButton.isEnabled = true
            
            
            
        } else {
            commnetButton.backgroundColor = UIColor(red: 0, green: 122/256, blue: 255/256, alpha: 0.5)
            commnetButton.isEnabled = false
        }
        
        let wordLimit = 100
    
        print("The numeber of remaining words are: \(wordLimit - (textView.text.count / 5))")
        
    }
    
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if range.length == 1{
            return true
        }else if (100 - textView.text.count / 5) <= 0 {
            return false
        } else {
            return true
        }
    }
    
    
    
    
    
    
}

extension StaticDetailTableViewController{
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return super.tableView(tableView, numberOfRowsInSection: section)
        } else {
            return comments.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            return super.tableView(tableView, cellForRowAt: indexPath)
        } else {
            let commentCell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.commentCell, for: indexPath) as! CommentCell
            
            commentCell.configureCell(with: comments[indexPath.row])
            return commentCell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 {
            return super.tableView(tableView, heightForHeaderInSection: section)
        } else {
            if let sectionOneHeaderViewContainerView = sectionOneHeaderViewContainerView{
                return sectionOneHeaderViewContainerView.bounds.height
            } else {
                return 0.0
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var height: CGFloat = 0.0
        if section == 0 {
            height = super.tableView(tableView, heightForFooterInSection: section)
        }
        return height
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return super.tableView(tableView, heightForRowAt: indexPath)
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        var indentationLevel = 0;
        if indexPath.section == 0 {
            indentationLevel = super.tableView(tableView, indentationLevelForRowAt: indexPath)
        }
        return indentationLevel
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return super.tableView(tableView, viewForHeaderInSection: section)
        } else {
            if let sectionOneHeaderViewContainerView = sectionOneHeaderViewContainerView{
                return sectionOneHeaderViewContainerView
            } else {
                return nil
            }
        }
    }
    
   
    
}




