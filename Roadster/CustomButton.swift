
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit

@IBDesignable class CustomButton: UIButton{
    
    @IBInspectable var cornerRadius: CGFloat{
        
        get{
            return layer.cornerRadius
        } set {
            layer.cornerRadius = newValue
            layer.masksToBounds = newValue > 0
        }
        
    }
    
    @IBInspectable var borderWidth: CGFloat{
        get {
            return layer.borderWidth
        } set {
            layer.borderWidth = newValue
            layer.masksToBounds = newValue > 0
        }
    }
    
    @IBInspectable var borderColor: UIColor{
        get {
            return UIColor(cgColor: layer.borderColor!)
        } set {
            layer.borderColor = newValue.cgColor
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 5.0
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func prepareForInterfaceBuilder() {
        cornerRadius = 5.0
    }
}
