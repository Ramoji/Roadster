
//  Copyright © 2016 A Ja. All rights reserved.
//

import UIKit

extension UIImage{
    
    func resizeImage( _ withSize: CGSize) -> UIImage{
        let widthRatio = withSize.width / size.width
        let heightRetio = withSize.height / size.height
        let newRatio = min(widthRatio, heightRetio)
        let newSize = CGSize(width: size.width * newRatio, height: size.height * newRatio)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        draw(in: CGRect(x: 0.0, y: 0.0, width: newSize.width, height: newSize.height))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
}

