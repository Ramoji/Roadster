//
//  UIViewExtensions.swift
//  Roadster
//
//  Created by A Ja on 12/25/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

import Foundation
import UIKit
import MapKit

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
        print("In hasExceeded method!: the constraint constant is: \(self.constant) AND the vertical upper limit is: \(verticalUpperLimit)")
        if self.constant < verticalUpperLimit{return true} else {return false}
    }
    
    func hasExceeded(middleLimit: CGFloat) -> Bool{
        return self.constant < middleLimit
    }
}


extension MKMapView{
    func findAnnotationFor(latitude: Double, longitude: Double) -> MKAnnotation?{
        var foundAnnotation: MKAnnotation?
        let annotations = self.annotations
        for annotation in annotations{
            if annotation.coordinate.latitude == latitude && annotation.coordinate.longitude == longitude{
                foundAnnotation = annotation
            }
        }
        
        return foundAnnotation
    }
    
    func deselectAnnotations(_ annotations: [MKAnnotation]){
        for annotation in annotations{
            self.deselectAnnotation(annotation, animated: true)
        }
    }
    
}

extension UIView{
    func findConstraint(for identifier: String) -> NSLayoutConstraint?{
        var foundConstraint: NSLayoutConstraint!
        for constraint in self.constraints{
            if constraint.identifier == identifier{
                foundConstraint = constraint
            }
        }
        return foundConstraint
    }
}








