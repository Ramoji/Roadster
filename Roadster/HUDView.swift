//
//  HUDView.swift
//  Roadster
//
//  Created by EA JA on 9/1/17.
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit
import Foundation
import Dispatch

class HUDView: UIView {

    var text: String!
    
    class func createHUD(inView view: UIView, animated: Bool) -> HUDView{
        let hudView = HUDView(frame: view.bounds)
        hudView.isOpaque = false
        hudView.tag = 1000
        view.addSubview(hudView)
        view.isUserInteractionEnabled = false
        hudView.show(animated: animated)
        return hudView
    }
    
    override func draw(_ rect: CGRect) {
        let boxWidth: CGFloat = 96
        let boxHeight: CGFloat = 96
        
        let boxRect = CGRect(x: round((bounds.size.width - boxWidth) / 2), y: round((bounds.size.height - boxHeight) / 2), width: boxWidth, height: boxHeight)
         let roundedRect = UIBezierPath(roundedRect: boxRect, cornerRadius: 10.0)
        UIColor(white: 0.3, alpha: 0.8).setFill()
        roundedRect.fill()
        
        let imagePoint = CGPoint(x: center.x - round(#imageLiteral(resourceName: "Checkmark").size.width / 2), y: center.y - round(#imageLiteral(resourceName: "Checkmark").size.height / 2) - boxHeight / 8)
        #imageLiteral(resourceName: "Checkmark").draw(at: imagePoint)
        
        let textAttributes = [NSFontAttributeName: UIFont.systemFont(ofSize: 16.0), NSForegroundColorAttributeName: UIColor.white]
        let textSize = text.size(attributes: textAttributes)
        
        let textPoint = CGPoint(x: center.x - round(textSize.width / 2), y: center.y - round(textSize.height / 2) + boxHeight / 4)
        
        text.draw(at: textPoint, withAttributes: textAttributes)
        
    }
    
    func show(animated: Bool){
        guard animated else {return}
        alpha = 0
        transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        
        UIView.animate(withDuration: 0.3, delay: 0.0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.5, options: [], animations: {
            self.alpha = 1
            self.transform = CGAffineTransform.identity
        }, completion: nil)
        
        
    }

}
