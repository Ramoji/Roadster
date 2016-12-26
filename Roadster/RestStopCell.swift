//
//  RestStopCell.swift
//  Roadster
//
//  Created by A Ja on 11/29/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

import UIKit

class RestStopCell: UITableViewCell {
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(with distanceFromUser: Int){
        self.distanceLabel.text = String(distanceFromUser) + " mi"
        self.distanceLabel.sizeToFit()
        self.backgroundColor = UIColor.clear
        self.accessoryType = .none
    }

}
