//
//  BusinessSearchResultFirstCell.swift
//  Roadster
//
//  Created by EA JA on 7/26/17.
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit

protocol BusinessSearchResultFirstCellDelegate: class{
    func didTapServiceButton(businessSearchResultFirstCell cell: BusinessSearchResultFirstCell, _ sender: UIButton)
}

class BusinessSearchResultFirstCell: UITableViewCell{
    
    var delegate: BusinessSearchResultFirstCellDelegate?
    
    @IBOutlet weak var bankButton: UIButton!
    @IBOutlet weak var coffeeButton: UIButton!
    @IBOutlet weak var foodButton: UIButton!
    @IBOutlet weak var gasButton: UIButton!
    @IBOutlet weak var groceryButton: UIButton!
    @IBOutlet weak var hospitalButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    @IBOutlet weak var restStopButton: UIButton!
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        prepareButtons()
    }
    
    func didTapButton(_ sender: UIButton){
        delegate?.didTapServiceButton(businessSearchResultFirstCell: self, sender)
    }
    
    func prepareButtons(){
        
        bankButton.setImage(UIImage(named: "bank")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: .normal)
        bankButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        coffeeButton.setImage(UIImage(named: "coffee")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: .normal)
        coffeeButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        foodButton.setImage(UIImage(named: "food")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: .normal)
        foodButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        gasButton.setImage(UIImage(named: "gas")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: .normal)
        gasButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        groceryButton.setImage(UIImage(named: "grocery")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: .normal)
        groceryButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        hospitalButton.setImage(UIImage(named: "hospital")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: .normal)
        hospitalButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        postButton.setImage(UIImage(named: "post")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: .normal)
        postButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        restStopButton.setImage(UIImage(named: "restStop")?.resizeImage(CGSize(width: 50.0, height: 50.0)).withRenderingMode(.alwaysOriginal), for: .normal)
        restStopButton.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
        backgroundColor = UIColor.clear
    }
    
    

}
