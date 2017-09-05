//
//  BlurredBackgroundView.swift
//  Roadster
//
//  Created by A Ja on 10/22/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

import UIKit

class BlurredBackgroundView: UIView{
    
    var imageView: UIImageView
    var blurEffectView: UIVisualEffectView
    
    override init(frame: CGRect){
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.extraLight)
        imageView = UIImageView(image: UIImage(named: "blurredImage2"))
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        super.init(frame: frame)
    }
    convenience init(frame: CGRect, addBackgroundPic: Bool) {
        self.init(frame: frame)
        
        if addBackgroundPic{
            addSubview(imageView)
        }
        addSubview(blurEffectView)
    }
    required convenience init?(coder aDecoder: NSCoder) {
        self.init(frame: CGRect.zero)
    }
    override func layoutSubviews() {
        imageView.frame = self.bounds
        blurEffectView.frame = self.bounds
    }
    
}
