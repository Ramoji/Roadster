//
//  YelpCommentCell.swift
//  Roadster
//
//  Created by EA JA on 8/20/17.
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit
import AlamofireImage

class YelpCommentCell: UITableViewCell {
    
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var ratingImageView: UIImageView!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.layer.cornerRadius = 20.0
        userImageView.clipsToBounds = true
        userImageView.layer.masksToBounds = true
        userImageView.contentMode = .scaleAspectFill
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(with comment: YelpComment){
        
        commentTextView.backgroundColor = UIColor.clear
        if let comment = comment.comment{
            commentTextView.text = comment
        }
        
        if let imageURL = comment.userImageURL{
            
            HTTPHelper.shared.getImage(from: imageURL){image in
                let imageWithNewSize = image.resizeImage(CGSize(width: 40.0, height: 40.0)).withRenderingMode(.alwaysOriginal)
                self.userImageView.image = imageWithNewSize
            }
            
            
        }
        
        
        
        if let rating = comment.rating{
            if let image = UIImage(named: "\(rating)stars"){
                ratingImageView.image = image.resizeImage(CGSize(width: 80.0, height: 17.0)).withRenderingMode(.alwaysOriginal)
            }
        }
        
        if let userName = comment.userName{
            ratingLabel.text = userName
        }
        
        if let commentDate = comment.commentDate{
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            let dateString = dateFormatter.string(from: commentDate)
            if let ratingText = ratingLabel.text{
                ratingLabel.text = ratingText.appending(" · \(dateString)")
            }
        }
    }

    
        
        
}
