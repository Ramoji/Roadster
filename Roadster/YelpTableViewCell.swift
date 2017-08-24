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
    @IBOutlet weak var businessAddress: UILabel!
    @IBOutlet weak var businessRatingLabel: UILabel!
    @IBOutlet weak var businessRatingImageView: UIImageView!
    
   

    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setUp(for yelpBusiness: YLPBusiness){
        prepareCell()
        backgroundColor = UIColor.clear
        businessRatingImageView.isHidden = false
        let businessTitleText = yelpBusiness.name.appending(" (\(yelpBusiness.categories[0].name))") as NSString
        let categoryRange = businessTitleText.range(of: " (\(yelpBusiness.categories[0].name))", options: .caseInsensitive)
        let categoryMutableString = NSMutableAttributedString(string: businessTitleText as String, attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15)])
        categoryMutableString.removeAttribute(NSFontAttributeName, range: categoryRange)
        categoryMutableString.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 13)], range: categoryRange)
        businessTitle.attributedText = categoryMutableString
        
        if !yelpBusiness.location.address.isEmpty{
            var addressText: NSString = yelpBusiness.location.address[0] as NSString
            if yelpBusiness.isClosed{
                addressText = addressText.appending(" · Closed now") as NSString
                let redColorRange = addressText.range(of: "Closed now", options: .caseInsensitive)
                let mutableString  = NSMutableAttributedString(string: addressText as String, attributes: [NSFontAttributeName: UIFont.systemFont(ofSize: 14.0)])
                mutableString.addAttributes([NSStrokeColorAttributeName: UIColor.red], range: redColorRange)
                businessAddress.attributedText = mutableString
            } else{
                businessAddress.text = addressText as String
                
            }
        }
        
        businessRatingImageView.contentMode = .scaleAspectFit
        businessRatingImageView.image = getRatingImage(for: yelpBusiness.rating).resizeImage(CGSize(width: 60.0, height: 15.0))
        businessRatingLabel.text = getRatingString(for: yelpBusiness)
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
            ratingString = "(\(String(yelpBusiness.reviewCount))) on Yelp ·" //add dollar sign price range.
            return ratingString
        }
    }
    
    private func setYelpBusinessImage(_ business: YLPBusiness){
        
    }
    
    public func prepareCell(){
        businessTitle.text = ""
        businessAddress.text = ""
        businessRatingLabel.text = ""
        businessRatingImageView.image = nil
    }
    
    func setUpHistoryCell(for business: HistoryYelpBusiness){
        prepareCell()
        backgroundColor = UIColor.clear
        let businessTitleText = business.name.appending(" (\(business.category))") as NSString
        let categoryRange = businessTitleText.range(of: " (\(business.category))", options: .caseInsensitive)
        let categoryMutableString = NSMutableAttributedString(string: businessTitleText as String, attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 15)])
        categoryMutableString.removeAttribute(NSFontAttributeName, range: categoryRange)
        categoryMutableString.addAttributes([NSFontAttributeName: UIFont.systemFont(ofSize: 13)], range: categoryRange)
        businessTitle.attributedText = categoryMutableString
        businessAddress.text = business.businessAddress
        
        businessRatingImageView.contentMode = .scaleAspectFit
        businessRatingImageView.image = getRatingImage(for: business.rating).resizeImage(CGSize(width: 60.0, height: 15.0))
        
        var ratingString = ""
        
        if business.reviewCount == 0 {
            ratingString = "No reviews"
        } else {
            ratingString = "(\(String(business.reviewCount))) on Yelp ·" //add dollar sign price range.
        }
        
        businessRatingLabel.text = ratingString
        
    }
}
