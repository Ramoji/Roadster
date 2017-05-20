//
//  StaticDetailTableViewController.swift
//  Roadster
//
//  Created by A Ja on 11/27/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

import UIKit
import MapKit

class StaticDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var distanceLabel: UILabel!
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
    @IBOutlet weak var parkingImageView: UIImageView!
    @IBOutlet weak var truck: UIImageView!
    @IBOutlet weak var sedanCar: UIImageView!
    @IBOutlet weak var trailer: UIImageView!
    
    
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commnetButton: UIButton!
    @IBOutlet weak var cancelComment: UIButton!
    @IBOutlet weak var ratingStars: UIImageView!
    
    @IBOutlet weak var commentTextViewHeightConstraint: NSLayoutConstraint!
    
    
    var restStop: USRestStop!
    var fullStateName: String!
    var bound = ""
    let blurredBackgroudView = BlurredBackgroundView(frame: CGRect.zero, addBackgroundPic: true)
    var comments: [Comment] = []

    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSegmentedControl()
        navigationItem.title = restStop.mileMarker
        setUpViewForRestStop()
        loadComments()
        
        ///////////
        var nib = UINib(nibName: "CommentCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "CommentCell")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 70
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.backgroundColor = UIColor.clear
        tableView.backgroundView = blurredBackgroudView
        setUpTableView()
    }
    
    override func loadView() {
        super.loadView()
        imageViews = [imageViewOne, imageViewTwo, imageViewThree, imageViewFour, imageViewFive, imageViewSix, imageViewSeven, imageViewEight, imageViewNine, imageViewTen]
    }
    
    func setUpTableView(){
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
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
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("***Receiving Memory Warning from StaticDetailTableViewController!")
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
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
        hideCommentButtons()
    }
    
    @IBAction func cancelComment(_ sender: UIButton) {
        hideCommentButtons()
    }
    
    @IBAction func commentSectionTapped(_ sender: Any) {
        hideCommentButtons()
    }
    
    func hideCommentButtons(){
        if commentTextView.isFirstResponder{
            commentTextView.resignFirstResponder()
            commentTextView.textColor = UIColor.lightGray
            commentTextView.text = "Add a public comment..."
            UIView.animate(withDuration: 0.5){
                self.commnetButton.center.y = 50
                self.commnetButton.alpha = 0.0
                self.cancelComment.center.y = 50
                self.cancelComment.alpha = 0.0
                self.ratingStars.center.y = 50
                self.ratingStars.alpha = 0.0
                self.commentTextViewHeightConstraint.constant = 40
                self.view.setNeedsLayout()
                self.commnetButton.isEnabled = false
                self.cancelComment.isEnabled = false
            }
        }
    }
    
    func loadComments(){
        HTTPHelper.getComments(restStop: restStop){ publicComments in
            self.comments = publicComments
            self.tableView.reloadData()
        }
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
        
        
        textView.text = ""
        textView.textColor = UIColor.black
        commnetButton.isHidden = false
        cancelComment.isHidden = false
        commnetButton.isEnabled = false
        ratingStars.isHidden = false
        commentTextView.translatesAutoresizingMaskIntoConstraints = false
        commnetButton.backgroundColor = UIColor(red: 0, green: 122/256, blue: 255/256, alpha: 0.5)
        UIView.animate(withDuration: 0.5){
            self.commnetButton.center.y = 77
            self.commnetButton.alpha = 1.0
            self.cancelComment.center.y = 77
            self.cancelComment.alpha = 1.0
            self.commentTextViewHeightConstraint.constant = 50
            self.ratingStars.center.y = 77
            self.ratingStars.alpha = 1.0
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
            let commentCell = tableView.dequeueReusableCell(withIdentifier: "CommentCell", for: indexPath) as! CommentCell
            commentCell.commentLabel.text = comments[indexPath.row].comment
            return commentCell
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var height: CGFloat = 0.0
        if section == 0 {
            height = super.tableView(tableView, heightForHeaderInSection: section)
        }
        return height
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
    
    
}




