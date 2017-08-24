//
//  CustomUIView.swift
//  Roadster
//
//  Created by EA JA on 7/13/17.
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit

@IBDesignable
class CustomUIView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 5.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBInspectable var cornorRadius: CGFloat{
        get{
            return layer.cornerRadius
            
        }
        
        set{
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    override func prepareForInterfaceBuilder() {
        layer.cornerRadius = 2.5
    }

}
