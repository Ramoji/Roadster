//
//  FacilitiesView.swift
//  Roadster
//
//  Created by EA JA on 3/4/17.
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit

class FacilitiesView: UIView {
    
    var facilityView: [UIView] = []
    
    override init(frame: CGRect){
        super.init(frame: frame)
        for _ in 1...12 {
            let facilityView = UIView()
            self.facilityView.append(facilityView)
        }
        
        print("FacilityView count is: \(facilityView.count)")
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    

}
