//
//  UILabel+Modify.swift
//  Roadster
//
//  Created by A Ja on 11/26/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

import Foundation
import UIKit

extension UILabel{
    var defaultNumberOfLines : Int{
        get{
            return numberOfLines
        }
        
        set{
            numberOfLines = newValue
        }
    }
}
