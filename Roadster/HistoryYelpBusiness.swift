//
//  HistoryYelpBusiness.swift
//  Roadster
//
//  Created by EA JA on 8/3/17.
//  Copyright © 2017 A Ja. All rights reserved.
//

import Foundation
import YelpAPI

class HistoryYelpBusiness: NSObject, NSCoding{
    var businessIdentifier: String
    var name: String
    var rating: Double
    var reviewCount: UInt
    var category: String
    var businessAddress: String
    
    init(business: YLPBusiness) {
        businessIdentifier = business.identifier
        name = business.name
        rating = business.rating
        reviewCount = business.reviewCount
        
        if !business.categories.isEmpty{
            category = business.categories[0].name
        } else {
            category = ""
        }
        
        if !business.location.address.isEmpty{
            businessAddress = business.location.address[0]
        } else {
            businessAddress = ""
        }
    }
    
    init(businessIdentifier: String, name: String, rating: Double, reviewCount: UInt, category: String, businessAddress: String) {
        self.businessIdentifier = businessIdentifier
        self.name = name
        self.rating = rating
        self.reviewCount = reviewCount
        self.category = category
        self.businessAddress = businessAddress
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        businessIdentifier = aDecoder.decodeObject(forKey: "businessIdentifier") as! String
        name = aDecoder.decodeObject(forKey: "name") as! String
        rating = aDecoder.decodeDouble(forKey: "rating")
        reviewCount = aDecoder.decodeObject(forKey: "reviewCount") as! UInt
        category = aDecoder.decodeObject(forKey: "category") as! String
        businessAddress = aDecoder.decodeObject(forKey: "businessAddress") as! String
    }
    
    func encode(with aCoder: NSCoder) {
        aCoder.encode(businessIdentifier, forKey: "businessIdentifier")
        aCoder.encode(name, forKey: "name")
        aCoder.encode(rating, forKey: "rating")
        aCoder.encode(reviewCount, forKey: "reviewCount")
        aCoder.encode(category, forKey: "category")
        aCoder.encode(businessAddress, forKey: "businessAddress")
    }
}
