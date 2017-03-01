//
//  YelpTableViewCell.swift
//  Roadster
//
//  Created by A Ja on 1/7/17.
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit
import YelpAPI
import Alamofire
import Dispatch

class YelpTableViewCell: UITableViewCell {
    
    @IBOutlet weak var businessTitle: UILabel!
    @IBOutlet weak var businessCatAndDistance: UILabel!
    @IBOutlet weak var businessRatingLabel: UILabel!
    @IBOutlet weak var businessRatingImageView: UIImageView!
    @IBOutlet weak var businessImageView: UIImageView!
    
   

    override func awakeFromNib() {
        super.awakeFromNib()
        businessImageView.contentMode = .scaleAspectFit
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUp(for yelpBusiness: YLPBusiness){
        backgroundColor = UIColor.clear
        businessRatingImageView.isHidden = false
        businessTitle.text = yelpBusiness.name
        businessCatAndDistance.text = yelpBusiness.categories.first!.name
        businessRatingImageView.contentMode = .scaleAspectFit
        businessRatingImageView.image = getRatingImage(for: yelpBusiness.rating).resizeImage(CGSize(width: 60.0, height: 15.0))
        businessRatingLabel.text = getRatingString(for: yelpBusiness)
        businessImageView.image = nil
        setYelpBusinessImage(yelpBusiness)
    }
    
    private func getRatingImage(for rating: Double)-> UIImage{
        let imageName = String(rating)+"stars"
        let ratingImage = UIImage(named: imageName)
        if let _ = ratingImage{
            return ratingImage!
        } else {
            return UIImage(named:"0stars")!
        }
    }
    
    private func getRatingString(for yelpBusiness: YLPBusiness) -> String{
        var ratingString = ""
        if yelpBusiness.reviewCount == 0{
            return "No Reviews"
        } else {
            ratingString = "(\(String(yelpBusiness.reviewCount))) on Yelp"
            return ratingString
        }
    }
    
    private func setYelpBusinessImage(_ business: YLPBusiness){
        let queue = DispatchQueue.global(qos: .userInitiated)
        let destination: DownloadRequest.DownloadFileDestination = {_, _ in
            let documentsURL = FileManager.default.urls(for: FileManager.SearchPathDirectory.documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)[0]
            let imageDestination = documentsURL.appendingPathComponent("yelpBusinessImage.png")
            
            return (imageDestination, [DownloadRequest.DownloadOptions.removePreviousFile, DownloadRequest.DownloadOptions.createIntermediateDirectories])
            
            }
        
        queue.async {
            
            if let imageURL = business.imageURL{
                Alamofire.download(imageURL, to: destination).responseData { response in
                    if let path = response.destinationURL?.path{
                        DispatchQueue.main.async {
                            self.businessImageView.image = UIImage(contentsOfFile: path)
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.businessImageView.image = UIImage(named: "NoImage")
                }
            }
        }
    }
}
