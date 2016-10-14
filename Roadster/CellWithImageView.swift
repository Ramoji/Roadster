//
//  CellWithImageView.swift
//  Roadster
//
//  Created by A Ja on 9/7/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

import UIKit

class CellWithImageView: UITableViewCell {

    @IBOutlet weak var stateImageView: UIImageView!
    @IBOutlet weak var stateNameLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(forState state: (String, String)) {
        stateNameLabel.text = state.0
        if let image = UIImage(named: "NoImage"){
            stateImageView.image = image
        }
        nicknameLabel.text = state.1
    }

}
