//
//  RoundCornorTableView.swift
//  Roadster
//
//  Created by EA JA on 2/28/17.
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit

extension UITableView {


    func roundCorners(withCornerRadius radius: CGFloat){
        layer.cornerRadius = radius
        clipsToBounds = true
    }
}
