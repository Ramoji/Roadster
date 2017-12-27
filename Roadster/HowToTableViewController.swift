
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit

class HowToTableViewController: UITableViewController {
    
    var guideImage: UIImage!
    var guideText: String!
    @IBOutlet var guideImageView: UIImageView!
    @IBOutlet var guideTextLabel: UILabel!
    

    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.rowHeight = UITableViewAutomaticDimension
        guideImageView.contentMode = .scaleAspectFit
        guideImageView.image = guideImage
        guideTextLabel.text = guideText
        tableView.backgroundView = BlurredBackgroundView(frame: self.tableView.bounds, addBackgroundPic: true)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: self.view.bounds.width, bottom: 0, right: 0)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 80.0
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        cell.backgroundColor = UIColor.clear
        return cell
        
    }

}
