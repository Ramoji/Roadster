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
        let stateName = state.0
        stateNameLabel.text = stateName
        if let image = UIImage(named: stateName.lowercased())?.resizeImage(CGSize(width: 62.0, height: 62.0)){
            stateImageView.image = image
            stateImageView.contentMode = UIViewContentMode.scaleAspectFit
        } else {
            stateImageView.image = UIImage(named: "NoImage")?.resizeImage(CGSize(width: 62.0, height: 62.0))
            stateImageView.contentMode = UIViewContentMode.scaleAspectFit
        }
        nicknameLabel.text = state.1
    }
    
    func configureCell(forHighway highway: String, stateAbbreviation: String, numberOfRestStops: Int){
        
        imageView?.image = nil
        stateNameLabel.text = ""
        nicknameLabel.text = ""
        stateNameLabel.text = highway
        nicknameLabel.text = String(numberOfRestStops) + " rest stops"
        imageView?.contentMode = UIViewContentMode.scaleAspectFit
        if highway.contains("I-") || highway.contains("US-"){
            if let image = UIImage(named: highway)?.resizeImage(CGSize(width: 62.0, height: 62.0)){
                imageView?.image = image
            } else {
                imageView?.image = UIImage(named: "NoImage")?.resizeImage(CGSize(width: 62.0, height: 62.0))
            }
        } else {
            
            if let image = UIImage(named: stateAbbreviation+"-"+highway)?.resizeImage(CGSize(width: 62.0, height: 62.0)){
                imageView?.image = image
            } else {
                imageView?.image = UIImage(named: "NoImage")?.resizeImage(CGSize(width: 62.0, height: 62.0))
            }
        }
        backgroundColor = UIColor.clear
    }
}
