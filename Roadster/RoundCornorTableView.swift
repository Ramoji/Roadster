
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit

extension UITableView {


    func roundCorners(withCornerRadius radius: CGFloat){
        layer.cornerRadius = radius
        clipsToBounds = true
    }
}
