//
//  CommentCell.swift
//  Roadster
//
//  Created by EA JA on 5/18/17.
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
        self.backgroundColor = UIColor.clear
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        
        userLabel.text = comment.username
        if let image = UIImage(named: "\(comment.rating)stars"){
            ratingImageView.image = image
        } else {
        }
        dateLabel.text = dateFormatter.string(from: (dateFormatter.date(from: comment.date))!)
        commentLabel.text = comment.comment
        
    }
    
}
