
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit

class UnorderedRestStopCell: UITableViewCell {

    @IBOutlet weak var highwayNameLabel: UILabel!
    @IBOutlet weak var mileMarkerLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var noRatingLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    //This method confgures the table view cell using the provided rest stop from the Core Data object graph
    func configureCell(with restStop: USRestStop, distanceFromUser: Int){
        
        prepSubviews()
        
        self.backgroundColor = UIColor.clear
        
        distanceLabel.text = "\(String(distanceFromUser)) miles"
        
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
    
    //This method configures the table view cell for user's search history using the object HistoryUSRestStop
    
    func configureHistoryCell(with restStop: HistoryUSRestStop, distanceFromUser: Int){
        
        prepSubviews()
        
        distanceLabel.text = "\(String(distanceFromUser)) miles"
        
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
    
    func configureCell(with favorite: Favorite){
        
        let distanceFromUser = 0
        
        prepSubviews()
        
        self.backgroundColor = UIColor.clear
        
        distanceLabel.text = "\(String(distanceFromUser)) miles"
        
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
    
    
    func configureFrequentCell(with frequent: Frequent){
        
        let distanceFromUser = 0
        
        prepSubviews()
        
        self.backgroundColor = UIColor.clear
        
        distanceLabel.text = "\(String(distanceFromUser)) miles"
        
        ratingImageView.contentMode = .scaleAspectFit
        
        let highwayString = "Rest stop on \(frequent.routeName)"
        
        highwayNameLabel.text = highwayString
        
        HTTPHelper.shared.getComments(latitude: frequent.latitude, longitude: frequent.longitude, reloadTableViewClosure: {
            
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
            
            self.ratingImageView.image = image.resizeImage(CGSize(width: 60.0, height:
                15.0)).withRenderingMode(.alwaysOriginal)
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
    
    //This mothod is called before the cell is configured to rest all text and images within the cell
    
    func prepSubviews(){
        
        highwayNameLabel.text = ""
        mileMarkerLabel.text = ""
        ratingImageView.image = nil
        noRatingLabel.text = ""
        
    }
    
}
