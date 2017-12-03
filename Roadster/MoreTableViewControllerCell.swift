//
//  MoreTableViewControllerCellTableViewCell.swift
//  Roadster
//
//  Created by EA JA on 10/5/17.
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit

class MoreTableViewControllerCell: UITableViewCell {
    
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var separator: UIView!

    override func awakeFromNib() {
        super.awakeFromNib()
        iconImageView.contentMode = .scaleAspectFit
        separator.backgroundColor = UIColor(red: 200/255, green: 199/255, blue: 204/255, alpha: 1.0)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
