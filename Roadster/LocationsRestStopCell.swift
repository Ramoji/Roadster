
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit
import CoreLocation

class LocationsRestStopCell: UITableViewCell {

    @IBOutlet weak var highwayNameLabel: UILabel!
    @IBOutlet weak var mileMarkerLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var noRatingLabel: UILabel!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var distanceLabel: UILabel!
    
    func configureCell(with restStop: USRestStop, distanceFromUser: Int){
        
        prepSubviews()
        
        iconImageView.image = #imageLiteral(resourceName: "restStop").resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
        
        self.backgroundColor = UIColor.clear
        
        
        ratingImageView.contentMode = .scaleAspectFit
        
        let highwayString = "Rest stop on \(restStop.routeName)"
        
        highwayNameLabel.text = highwayString
        
        HTTPHelper.shared.getComments(latitude: restStop.latitude, longitude: restStop.longitude, reloadTableViewClosure: {
            
            comments, rating in
            
            var image: UIImage {
                
                if rating == 0 {
                    
                    self.noRatingLabel.text = "No ratings"
                    
                    return #imageLiteral(resourceName: "0stars")
                    
                }
                
                guard let image = UIImage(named: String(rating) + "stars") else {
                    
                    return #imageLiteral(resourceName: "0stars")
                }
                
                return image
            }
            
            self.ratingImageView.image = image.resizeImage(CGSize(width: 60.0, height: 15.0)).withRenderingMode(.alwaysOriginal)
            
        })
        
        var mileMarkerString: String {
            
            if restStop.mileMarker.isEmpty{
                
                return "No mile marker information"
                
            } else {
                
                return restStop.mileMarker
                
            }
            
        }
        
        mileMarkerLabel.text = mileMarkerString
        
    }
    
    func configureHistoryCell(with restStop: HistoryUSRestStop, distanceFromUser: Int){
        
        prepSubviews()
        
        iconImageView.image = #imageLiteral(resourceName: "restStop").resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
        
        ratingImageView.contentMode = .scaleAspectFit
        
        self.backgroundColor = UIColor.clear
        
        let highwayString = "Rest stop on \(restStop.routeName)"
        
        highwayNameLabel.text = highwayString
        
        HTTPHelper.shared.getComments(latitude: restStop.latitude, longitude: restStop.longitude, reloadTableViewClosure: { comments, rating in
            
            var image: UIImage {
                
                if rating == 0 {self.noRatingLabel.text = "No ratings"}
                
                guard let image = UIImage(named: String(rating)) else {
                    
                    return #imageLiteral(resourceName: "0stars")
                    
                }
                
                return image
                
            }
            
            self.ratingImageView.image = image.resizeImage(CGSize(width: 60.0, height: 15.0)).withRenderingMode(.alwaysOriginal)
            
        })
        
        var mileMarkerString: String {
            
            if restStop.mileMarker != "" || restStop.mileMarker != " "{
                
                return restStop.mileMarker
                
            } else {
                
                return "No mile marker information"
                
            }
            
        }
        
        mileMarkerLabel.text = mileMarkerString
        
    }
    
    func configureCell(with favorite: Favorite, currentUserLocation: CLLocation?){
        
        prepSubviews()
        
        if let currentUserLocation = currentUserLocation{
            
            distanceLabel.isHidden = false
            
            let stopLocation = CLLocation(latitude: favorite.latitude, longitude: favorite.longitude)
            
            let distanceFromUser = (round((currentUserLocation.distance(from: stopLocation) / 1609) * 10)) / 10
            
            if distanceFromUser == 0 {
                
                distanceLabel.text = "Near by"
                
            }else if distanceFromUser < 1 {
                
                distanceLabel.text = "\(distanceFromUser) mi"
                
            } else {
                
                distanceLabel.text = "\(Int(distanceFromUser)) mi"
            }
            
        } else {
            
            distanceLabel.isHidden = true
            
        }
        
        iconImageView.image = #imageLiteral(resourceName: "restStop").resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
        
        self.backgroundColor = UIColor.clear
        
        ratingImageView.contentMode = .scaleAspectFit
        
        let highwayString = "Rest stop on \(favorite.routeName)"
        
        highwayNameLabel.text = highwayString
        
        HTTPHelper.shared.getComments(latitude: favorite.latitude, longitude: favorite.longitude, reloadTableViewClosure: {
            
            comments, rating in
            
            var image: UIImage {
                
                if rating == 0 {
                    
                    self.noRatingLabel.text = "No ratings"
                    
                    return #imageLiteral(resourceName: "0stars")
                    
                }
                guard let image = UIImage(named: String(rating) + "stars") else {
                    
                    return #imageLiteral(resourceName: "0stars")
                    
                }
                
                return image
            }
            
            self.ratingImageView.image = image.resizeImage(CGSize(width: 60.0, height: 15.0)).withRenderingMode(.alwaysOriginal)
            
        })
        
        var mileMarkerString: String {
            
            if favorite.mileMaker.isEmpty{
                
                return "No mile marker information"
                
            } else {
                
                return favorite.mileMaker
                
            }
        }
        
        mileMarkerLabel.text = mileMarkerString
        
    }
    
    
    func configureFrequentCell(with frequent: Frequent, currentUserLocation: CLLocation?){
        
        prepSubviews()
        
        if let currentUserLocation = currentUserLocation{
            
            distanceLabel.isHidden = false
            
            let stopLocation = CLLocation(latitude: frequent.latitude, longitude: frequent.longitude)
            
            let distanceFromUser = (round((currentUserLocation.distance(from: stopLocation) / 1609) * 10)) / 10
            
            if distanceFromUser == 0 {
                
                distanceLabel.text = "Near by"
                
            }else if distanceFromUser < 1 {
                
                distanceLabel.text = "\(distanceFromUser) mi"
                
            } else {
                
                distanceLabel.text = "\(Int(distanceFromUser)) mi"
            }
            
        } else {
            
            distanceLabel.isHidden = true
            
        }
        
        iconImageView.image = #imageLiteral(resourceName: "restStop").resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)

        self.backgroundColor = UIColor.clear
        
        
        ratingImageView.contentMode = .scaleAspectFit
        
        let highwayString = "Rest stop on \(frequent.routeName)"
        
        highwayNameLabel.text = highwayString
        
        HTTPHelper.shared.getComments(latitude: frequent.latitude, longitude: frequent.longitude, reloadTableViewClosure: { comments, rating in
            
            var image: UIImage {
                
                if rating == 0 {
                    
                    self.noRatingLabel.text = "No ratings"
                    
                    return #imageLiteral(resourceName: "0stars")
                    
                }
                
                guard let image = UIImage(named: String(rating) + "stars") else {
                    
                    return #imageLiteral(resourceName: "0stars")
                    
                }
                
                return image
            }
            
            self.ratingImageView.image = image.resizeImage(CGSize(width: 60.0, height: 15.0)).withRenderingMode(.alwaysOriginal)
            
        })
        
        var mileMarkerString: String {
            
            if frequent.mileMaker.isEmpty{
                
                return "No mile marker information"
                
            } else {
                
                return frequent.mileMaker
                
            }
            
        }
        
        mileMarkerLabel.text = mileMarkerString
    }
    
    //This method is called before configuring this cell to clear out any text or image
    func prepSubviews(){
        iconImageView.image = nil
        highwayNameLabel.text = ""
        mileMarkerLabel.text = ""
        ratingImageView.image = nil
        noRatingLabel.text = ""
        distanceLabel.text = ""
    }
}
