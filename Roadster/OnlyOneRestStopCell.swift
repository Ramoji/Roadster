
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit

class OnlyOneRestStopCell: UITableViewCell {
    
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
    @IBOutlet weak var imageViewThirteen: UIImageView!
    @IBOutlet weak var imageViewFourteen: UIImageView!
    @IBOutlet weak var restStopName: UILabel!
    @IBOutlet weak var noFacilitiesLabel: UILabel!
    @IBOutlet weak var closedLabel: UILabel!
    var imageViews: [UIImageView]!

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
        noFacilitiesLabel.isHidden = true
        closedLabel.isHidden = true
        for imageView in imageViews{
            imageView.isHidden = true
            imageView.image = nil
        }
    }
    
    func configureCell(with distanceFromUser: Int, restStop: USRestStop){
        prepViews()
        restStopName.text = restStop.mileMarker
        restStopName.sizeToFit()
        if restStop.facilities{
            let facilites = POIProvider.getFacilityList(forRestStop: restStop)
            for (index, facility) in facilites.enumerated(){
                let imageSize = CGSize(width: 20.0, height: 20.0)
                let facilityImageView = imageViews![index]
                facilityImageView.isHidden = false
                facilityImageView.image = UIImage(named: facility)?.resizeImage(imageSize)
            }
        } else {
            noFacilitiesLabel.isHidden = false
        }
        
        if restStop.closed{
            closedLabel.isHidden = false
        }
        
        self.distanceLabel.text = String(distanceFromUser) + " mi"
        self.distanceLabel.sizeToFit()
        self.backgroundColor = UIColor.clear
        self.accessoryType = .disclosureIndicator
        
    }
    


}
