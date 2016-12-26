//
//  ThirdViewController.swift
//  Roadster
//
//  Created by A Ja on 10/22/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

import UIKit
import MapKit

protocol RestStopDetailDisclosureViewControllerDelegate: class {
    func restStopDetailDisclosureDidClose(_ viewController: RestStopDetailDisclosureViewController)
    func restStopDetailDisclosureDidPick(_ viewController: RestStopDetailDisclosureViewController, mapType type: MKMapType)
}

class RestStopDetailDisclosureViewController: UIViewController {
    
    var delegate: RestStopDetailDisclosureViewControllerDelegate!
    var tapGestureRecognizer: UITapGestureRecognizer!
    var segmentedControl: UISegmentedControl!
    var myView: UIView!
    var restStop: USRestStop!
    var titleLabel: UILabel!
    var states: States!
    var fullStateName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        setUpDetailDisclosureSubView()
        setUpDismissTapGestureRecognizer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("***Receiving Memory Warning from RestStopDetailDisclosureViewController!")
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
    }
    
    override func viewWillLayoutSubviews() {
        segmentedControl.frame = CGRect(x: myView.bounds.size.width - (segmentedControl.frame.size.width + 15), y: 15, width: segmentedControl.frame.width, height: segmentedControl.frame.size.height)
        titleLabel.frame = CGRect(x: 15, y: 50, width: titleLabel.frame.size.width / 2, height: titleLabel.frame.size.height)
    }
    
    func setUpDetailDisclosureSubView(){
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: view.bounds.size.width - 50, height: view.bounds.size.height - 50), cornerRadius: 15)
        let pathRect = CGRect(x: 0, y: 125, width: view.bounds.size.width - 50 , height: view.bounds.size.width - 170)
        let rectPath = UIBezierPath(rect: pathRect)
        path.append(rectPath)
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        fillLayer.fillRule = kCAFillRuleEvenOdd
        fillLayer.fillColor = UIColor.white.cgColor
        let myFrame = CGRect(x: 25, y: 25, width: view.bounds.size.width - 50, height: view.bounds.size.height - 50)
        myView = UIView(frame: myFrame)
        myView.layer.insertSublayer(fillLayer, below: myView.layer)
        
        setUpSegmentedControl()
        setUpTitleLabel()
        view.addSubview(myView)
        view.setNeedsLayout()
        
        
    }
    
    func changeMapType(){
        switch segmentedControl.selectedSegmentIndex{
        case 0:
            delegate?.restStopDetailDisclosureDidPick(self, mapType: .standard)
        case 1:
            delegate?.restStopDetailDisclosureDidPick(self, mapType: .hybrid)
        default:
            fatalError("Error while calling delegate method to set RestStopListMapViewController's map type.")
        }
    }
    
    func setUpSegmentedControl(){
        segmentedControl = UISegmentedControl(items: ["Map","Satellite"])
        segmentedControl.addTarget(self, action: #selector(changeMapType), for: .valueChanged)
        segmentedControl.frame = CGRect.zero
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.sizeToFit()
        myView.addSubview(segmentedControl)
        view.setNeedsLayout()
    }
    
    func setUpTitleLabel(){
        let font = UIFont(name: "HelveticaNeue", size: 14)
        let text = NSAttributedString(string: "Rest Stop on \(restStop.routeName) in \(fullStateName!)", attributes: [NSFontAttributeName: font])
        UILabel.appearance().defaultNumberOfLines = 0
        titleLabel = UILabel(frame: CGRect.zero)
        titleLabel.attributedText = text
        titleLabel.sizeToFit()
        
        myView.addSubview(titleLabel)
    }
    
    func addFacilitiesView(to myView: UIView){
        let facilitiesViewRect = CGRect(x: 12, y: 500, width: 300, height: 60)
        let facilitiesView = UIView(frame: facilitiesViewRect)
        let facilitiesViewColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
        facilitiesView.backgroundColor = facilitiesViewColor
        facilitiesView.layer.cornerRadius = 10
        myView.addSubview(facilitiesView)
        addFacilitieIcons(to: facilitiesView)
    }
    
    func addFacilitieIcons(to facilitiesView: UIView){
        
    }
    
    func closeDetailDisclosureView(){
        dismiss(animated: true, completion: nil)
    }
    
    func setUpDismissTapGestureRecognizer(){
        tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dissmissObject))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func dissmissObject(){
        if let tapGestureRecognizer = tapGestureRecognizer{
            if tapGestureRecognizer.view === self.view {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    deinit {
        delegate?.restStopDetailDisclosureDidClose(self)
        print("RestStopDetailDisclosureViewController deallocated!")
    }
    
}

extension RestStopDetailDisclosureViewController: UIViewControllerTransitioningDelegate{
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        let customPresentationController = CustomUIPresentationController(presentedViewController: presented, presenting: presenting)
        return customPresentationController
    }
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentationAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissAnimator()
    }
}
