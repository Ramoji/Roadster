//
//  ThirdViewController.swift
//  Roadster
//
//  Created by A Ja on 10/22/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

import UIKit

protocol RestStopDetailDisclosureViewControllerDelegate: class {
    func restStopDetailDisclosureDidClose(_ viewController: RestStopDetailDisclosureViewController)
}

class RestStopDetailDisclosureViewController: UIViewController {
    
    var delegate: RestStopDetailDisclosureViewControllerDelegate!
    var tapGestureRecognizer: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.clear
        setUpDetailDisclosureSubView()
        setUpDismissTapGestureRecognizer()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.modalPresentationStyle = .custom
        self.transitioningDelegate = self
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
        let myView = UIView(frame: myFrame)
        myView.layer.insertSublayer(fillLayer, below: myView.layer)
        
       
        let closeButton = UIButton(type: .custom)
        closeButton.frame = CGRect(x: 10, y: 10, width: 20, height: 20)
        closeButton.contentMode = UIViewContentMode.scaleAspectFit
        let closeButtonImage = UIImage(named: "CloseButton")?.resizeImage(CGSize(width: 20, height: 20))
        closeButton.setImage(closeButtonImage, for: .normal)
        closeButton.layer.cornerRadius = 10
        closeButton.clipsToBounds = true
        closeButton.backgroundColor = UIColor.clear
        closeButton.addTarget(self, action: #selector(closeDetailDisclosureView), for: UIControlEvents.touchUpInside)
        myView.addSubview(closeButton)
        addFacilitiesView(to: myView)
        print(myView.bounds.size.width)
        print(myView.bounds.size.height)
        view.addSubview(myView)
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
        let i = 12
        //for i in 1...12{
            let imageView = UIImageView(frame: CGRect(x: 10, y: 10, width: 26, height: 26))
            imageView.image = UIImage(named: "dog")?.resizeImage(CGSize(width: 26, height: 26))
            imageView.layer.cornerRadius = 7
            imageView.clipsToBounds = true
            facilitiesView.addSubview(imageView)
        //}
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
