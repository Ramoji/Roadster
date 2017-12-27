
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit

class IconManualTableViewController: UITableViewController {
    
    @IBOutlet weak var disabledFacilitiesImageView: UIImageView!
    @IBOutlet weak var favoriteImageView: UIImageView!
    @IBOutlet weak var frequentImageView: UIImageView!
    @IBOutlet weak var gasImageView: UIImageView!
    @IBOutlet weak var navigateImageView: UIImageView!
    @IBOutlet weak var parkingImageView: UIImageView!
    @IBOutlet weak var petAreaImageView: UIImageView!
    @IBOutlet weak var phoneImageView: UIImageView!
    @IBOutlet weak var restaurantImageView: UIImageView!
    @IBOutlet weak var restroomImageView: UIImageView!
    @IBOutlet weak var rvDumpFacilitiesImageView: UIImageView!
    @IBOutlet weak var scenicImageView: UIImageView!
    @IBOutlet weak var sedanImageView: UIImageView!
    @IBOutlet weak var tablesImageView: UIImageView!
    @IBOutlet weak var truckImageView: UIImageView!
    @IBOutlet weak var vendingMachineImageView: UIImageView!
    @IBOutlet weak var waterImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        disabledFacilitiesImageView.image = getResizedIconImage(image: #imageLiteral(resourceName: "disabledFacilities"))
        favoriteImageView.image = getResizedIconImage(image: #imageLiteral(resourceName: "favoriteOff"))
        frequentImageView.image = getResizedIconImage(image: #imageLiteral(resourceName: "frequentOff"))
        gasImageView.image = getResizedIconImage(image: #imageLiteral(resourceName: "gas"))
        navigateImageView.image = getResizedIconImage(image: #imageLiteral(resourceName: "navigate"))
        parkingImageView.image = getResizedIconImage(image: #imageLiteral(resourceName: "parking"))
        petAreaImageView.image = getResizedIconImage(image: #imageLiteral(resourceName: "petArea"))
        phoneImageView.image = getResizedIconImage(image: #imageLiteral(resourceName: "phone"))
        restaurantImageView.image = getResizedIconImage(image: #imageLiteral(resourceName: "restaurant"))
        restroomImageView.image = getResizedIconImage(image: #imageLiteral(resourceName: "restroom"))
        rvDumpFacilitiesImageView.image = getResizedIconImage(image: #imageLiteral(resourceName: "rvDump"))
        scenicImageView.image = getResizedIconImage(image: #imageLiteral(resourceName: "scenic"))
        sedanImageView.image = getResizedIconImage(image: #imageLiteral(resourceName: "sedan"))
        tablesImageView.image = getResizedIconImage(image: #imageLiteral(resourceName: "tables"))
        truckImageView.image = getResizedIconImage(image: #imageLiteral(resourceName: "truck"))
        vendingMachineImageView.image = getResizedIconImage(image: #imageLiteral(resourceName: "vendingMachine"))
        waterImageView.image = getResizedIconImage(image: #imageLiteral(resourceName: "water"))
        

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    func getResizedIconImage(image: UIImage) -> UIImage{
        return image.resizeImage(CGSize(width: 30.0, height: 30.0)).withRenderingMode(.alwaysOriginal)
    }

}
