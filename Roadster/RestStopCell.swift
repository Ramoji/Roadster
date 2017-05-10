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
    @IBOutlet weak var imageViewOne: UIImageView!
    @IBOutlet weak var imageViewTwo: UIImageView!
    @IBOutlet weak var imageViewThree: UIImageView!
    @IBOutlet weak var imageViewFour: UIImageView!
    @IBOutlet weak var imageViewFive: UIImageView!
    @IBOutlet weak var imageViewSix: UIImageView!
    @IBOutlet weak var imageViewSeven: UIImageView!
    @IBOutlet weak var imageViewEight: UIImageView!
    @IBOutlet weak var imageViewNine: UIImageView!
    @IBOutlet weak var imageViewTen: UIImageView!
    @IBOutlet weak var imageViewEleven: UIImageView!
    @IBOutlet weak var imageViewTwelve: UIImageView!
    var imageViews: [UIImageView]!
    @IBOutlet weak var restStopName: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageViews = [imageViewOne, imageViewTwo, imageViewThree, imageViewFour, imageViewFive, imageViewSix, imageViewSeven, imageViewEight, imageViewNine, imageViewTen, imageViewEleven, imageViewTwelve]
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    private func prepViews(){
        restStopName.text = ""
        for imageView in imageViews{
            imageView.isHidden = true
            imageView.image = nil
        }
    }
    
    func configureCell(with distanceFromUser: Int, restStop: USRestStop){
        prepViews()
        restStopName.text = restStop.mileMarker
        restStopName.sizeToFit()
        let facilites = getAvailableFacilities(from: restStop)
        for (index, facility) in facilites.enumerated(){
            let imageSize = CGSize(width: 20.0, height: 20.0)
            let facilityImageView = imageViews![index]
            facilityImageView.isHidden = false
            facilityImageView.image = UIImage(named: facility)?.resizeImage(imageSize)
        }
        
        self.distanceLabel.text = String(distanceFromUser) + " mi"
        self.distanceLabel.sizeToFit()
        self.backgroundColor = UIColor.clear
        self.accessoryType = .disclosureIndicator
    
    }
    
    private func getAvailableFacilities(from restStop: USRestStop) -> [String]{
        
        var facilites: [String] = []
        
        if restStop.water {
            facilites.append("drinkingWater")
        }
        if restStop.restaurant {
            facilites.append("restaurant")
        }
        if restStop.gas {
            facilites.append("gas")
        }
        
        if restStop.disabledFacilities{
            facilites.append("handicappedFacilites")
        }
        
        if restStop.trucks {
            facilites.append("truck")
        }
        if restStop.petArea{
            facilites.append("petArea")
        }
        if restStop.phone{
            facilites.append("phone")
        }
        if restStop.tables{
            facilites.append("picnicTable")
        }
        if restStop.restroom
        {
            facilites.append("restroom")
        }
        if restStop.rvDump{
            facilites.append("rvDump")
        }
        if restStop.scenic{
            facilites.append("scenic")
        }
        if restStop.vendingMachine{
            facilites.append("vendingMachine")
        }
        
        return facilites
    }

}

