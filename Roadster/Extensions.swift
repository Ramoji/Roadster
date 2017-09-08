//
//  UIViewExtensions.swift
//  Roadster
//
//  Created by A Ja on 12/25/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

import Foundation
import UIKit

extension UIView{
    
    func addShadow(withCornerRadius: CGFloat){
        self.layer.cornerRadius = withCornerRadius
        self.layer.masksToBounds = false
        let shadowPath = UIBezierPath(roundedRect: self.bounds, cornerRadius: withCornerRadius)
        self.layer.shadowPath = shadowPath.cgPath
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0.2, height: 0)
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = 2.0
        
    }
    
}

extension Double {
    func convertToString() -> String {
        return String(self)
    }
    
    func roundToNearestHalf() -> Double{
        return (self * 2).rounded() / 2
    }
}

extension NSLayoutConstraint{
    func hasExceeded(verticalUpperLimit:  CGFloat) -> Bool{
        return self.constant < verticalUpperLimit
    }
    
    func hasExceeded(middleLimit: CGFloat) -> Bool{
        return self.constant < middleLimit
    }
}







