//
//  CustomUIPresentationController.swift
//  Roadster
//
//  Created by A Ja on 10/30/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

import UIKit

class CustomUIPresentationController: UIPresentationController {
    var myView: UIView!
    override func presentationTransitionWillBegin() {
       drawSeeThroughWindow()
        let transitionCoordinator = presentingViewController.transitionCoordinator
        myView.alpha = 0
        transitionCoordinator?.animate(alongsideTransition: {_ in
            self.myView.alpha = 1
        }, completion: nil)
    }
    
    override var shouldRemovePresentersView: Bool {return false}
    
    func drawSeeThroughWindow(){
        if let containerView = containerView{
            myView = UIView(frame: containerView.bounds)
            let path = UIBezierPath(roundedRect: containerView.bounds, cornerRadius: 0)
            let squarePathRect = CGRect(x: containerView.bounds.size.width / 2 - ((containerView.bounds.size.width - 50) / 2), y: containerView.bounds.size.height / 2 - ((containerView.bounds.size.height - 50) / 2), width: containerView.bounds.size.width - 50, height: containerView.bounds.size.height - 50)
            let squarePath = UIBezierPath(roundedRect: squarePathRect, cornerRadius: 15)
            path.append(squarePath)
            
            let fillLayer = CAShapeLayer()
            fillLayer.path = path.cgPath
            fillLayer.fillRule = kCAFillRuleEvenOdd
            fillLayer.fillColor = UIColor.black.cgColor
            fillLayer.opacity = 0.7
            myView.layer.addSublayer(fillLayer)
            containerView.insertSubview(myView, at: 0)
        }
    }
}
