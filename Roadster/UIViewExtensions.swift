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
        
        let shadowPath = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height), cornerRadius: withCornerRadius)
        self.layer.shadowPath = shadowPath.cgPath
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOffset = CGSize(width: 0.2, height: 0)
        self.layer.shadowOpacity = 0.3
        self.layer.shadowRadius = 2.0
        self.layer.masksToBounds = false
        
    }
    
}



