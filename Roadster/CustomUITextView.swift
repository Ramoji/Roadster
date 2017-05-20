//
//  UITextViewBlackBorder.swift
//  Roadster
//
//  Created by EA JA on 5/12/17.
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit

@IBDesignable
class CustomUITextView: UITextView {
    
    
    @IBInspectable var borderWidth: CGFloat{
        get{
            return layer.borderWidth
        } set {
            layer.borderWidth = newValue
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat{
        get{
            return layer.cornerRadius
        }
        set{
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderColor: UIColor?{
        
        get {
            return UIColor(cgColor: layer.borderColor!)
        } set {
            layer.borderColor = newValue?.cgColor
        }
        
    }

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        layer.borderWidth = 0
        layer.borderColor = UIColor.black.cgColor
        layer.cornerRadius = 5
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForInterfaceBuilder() {
        borderWidth = 1
        borderColor = UIColor.black
        cornerRadius = 5
    }

}
