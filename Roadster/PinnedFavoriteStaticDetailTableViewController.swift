//
//  PinnedFavoriteStaticDetailTableViewController.swift
//  Roadster
//
//  Created by EA JA on 9/29/17.
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit
import MapKit

class PinnedFavoriteStaticDetailTableViewController: UITableViewController {
    
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
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    
    @IBOutlet weak var truck: UIImageView!
    @IBOutlet weak var sedanCar: UIImageView!
    @IBOutlet weak var trailer: UIImageView!
    
    var imageViews: [UIImageView]!
    
    
    var favorite: Favorite!
    var fullStateName: String!
    
    var sectionOneHeaderViewContainerView: UIView!
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    let blurredBackgroudView = BlurredBackgroundView(frame: CGRect.zero, addBackgroundPic: true)
    var comments: [Comment] = []
    var averageRating: Double = 0.0
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.backgroundView = BlurredBackgroundView(frame: self.view.bounds, addBackgroundPic: true)
        registerNibs()
        sectionOneHeaderViewContainerView = getSectionOneHeaderView()
        setUpSegmentedControl()
        navigationItem.title = favorite.mileMaker
        setUpViewForFavorite()
        loadComments()
        
        

      
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func loadView(){
        super.loadView()
        
        imageViews = [imageViewOne, imageViewTwo, imageViewThree, imageViewFour, imageViewFive, imageViewSix, imageViewSeven, imageViewEight, imageViewNine, imageViewTen]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0{
            let cell = super.tableView(tableView, cellForRowAt: indexPath)
            cell.backgroundColor = UIColor.clear
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: CustomCellTypeIdentifiers.commentCell, for: indexPath) as! CommentCell
            cell.configureCell(with: comments[indexPath.row])
            return cell
        }
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return super.tableView(tableView, numberOfRowsInSection: section)
        } else {
            return comments.count
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return super.tableView(tableView, heightForRowAt: indexPath)
        } else {
            return 88.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionOneHeaderViewContainerView.bounds.height
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionOneHeaderViewContainerView
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
    
    func setUpViewForFavorite(){
        
        ratingImageView.contentMode = .scaleAspectFit
        
        let iconSize = CGSize(width: 25.0, height: 25.0)
        
        if let ratingImage = UIImage(named: "\(averageRating)stars"){
            ratingImageView.image = ratingImage.resizeImage(CGSize(width: ratingImageView.bounds.width, height:ratingImageView.bounds.height)).withRenderingMode(.alwaysOriginal)
        }
        
        let vehicleIconSize = CGSize(width: 25.0, height: 25.0)
        prepIconViews()
        if let favorite = favorite, let fullStateName = fullStateName{
            titleLabel.text = "Rest Stop on \((favorite.routeName as NSString)) in \(fullStateName.capitalized)"
            mapView.addAnnotation(favorite)
            latitudeLabel.text =  favorite.latitude.convertToString()
            longitudeLabel.text = favorite.longitude.convertToString()
            parkingImageView.image = UIImage(named: "parking")?.resizeImage(iconSize)
            sedanCar.image = UIImage(named: "sedan")?.resizeImage(iconSize)
            if favorite.rvDump{
                trailer.image = UIImage(named: "rvDump")?.resizeImage(vehicleIconSize)
            }
            if favorite.trucks{
                truck.image = UIImage(named: "truck")?.resizeImage(vehicleIconSize)
            }
            parkingImageView.image = UIImage(named: "parking")?.resizeImage(iconSize)
        }
        
        setUpMapView()
        configureFacilityIcons()
        
        view.setNeedsLayout()
        
    }
    
    private func registerNibs(){
        let nib = UINib(nibName: CustomCellTypeIdentifiers.commentCell, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: CustomCellTypeIdentifiers.commentCell)
    }
    
    private func prepIconViews(){
        for imageView in imageViews{
            imageView.isHidden = true
            imageView.image = nil
        }
    }
    
    func setUpMapView(){
        if let favorite = favorite{
            let region = MKCoordinateRegionMakeWithDistance(favorite.coordinate, 500, 500)
            mapView.setRegion(region, animated: true)
            mapView.isUserInteractionEnabled = false
        }
    }
    private func configureFacilityIcons(){
        let facilites = POIProvider.getFacilityList(forRestStop: favorite)
        for (index, facility) in facilites.enumerated(){
            let imageSize = CGSize(width: 20.0, height: 20.0)
            let facilityImageView = imageViews![index]
            facilityImageView.isHidden = false
            facilityImageView.image = UIImage(named: facility)?.resizeImage(imageSize)
        }
    }
    
    func loadComments(){
        HTTPHelper.shared.getComments(latitude: favorite.latitude, longitude: favorite.longitude){ publicComments, averageRating in
            self.comments = publicComments
            self.averageRating = averageRating
            self.tableView.reloadData()
            self.setUpViewForFavorite()
        }
    }
    
    @IBAction func navigateToFavorite(){
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: favorite.coordinate))
        var stopName = ""
        stopName = "Rest stop on \(favorite.routeName)"
        if !favorite.mileMaker.isEmpty{
            stopName = "Rest stop on \(favorite.routeName) (\(favorite.mileMaker))"
        }
        mapItem.name = stopName
        mapItem.openInMaps(launchOptions: [:])
    }

}
