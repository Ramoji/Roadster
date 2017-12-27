
//  Copyright © 2017 A Ja. All rights reserved.
//

import Foundation
import UIKit

class CommentCell: UITableViewCell{
    
    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    func configureCell(with comment: Comment){
        
        let firstName = comment.firstname.capitalized
        let firstLetterOfLastname = comment.lastname.capitalized.first
        
        ratingImageView.contentMode = .scaleAspectFit
        self.backgroundColor = UIColor.clear
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        
        if let  firstLetterOfLastname = firstLetterOfLastname{
            userLabel.text = firstName + " " + String(firstLetterOfLastname) + "."
        } else {
            userLabel.text = firstName
        }
    
        if let image = UIImage(named: "\(comment.rating)stars"){
            ratingImageView.image = image.resizeImage(CGSize(width: ratingImageView.bounds.width, height: ratingImageView.bounds.height)).withRenderingMode(.alwaysOriginal)
        } else {
            ratingImageView.image = #imageLiteral(resourceName: "0stars").resizeImage(CGSize(width: ratingImageView.bounds.width, height: ratingImageView.bounds.height)).withRenderingMode(.alwaysOriginal)
        }
        if let date = dateFormatter.date(from: comment.date){
            
            dateFormatter.dateStyle = .medium
            dateLabel.text = dateFormatter.string(from: date)
            
        }
        commentLabel.text = comment.comment
    }
    
}
