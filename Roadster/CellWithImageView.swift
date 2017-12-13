//
//  CellWithImageView.swift
//  Roadster
//
//  Created by A Ja on 9/7/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

import UIKit

class CellWithImageView: UITableViewCell {

    @IBOutlet weak var stateImageView: UIImageView!
    @IBOutlet weak var stateNameLabel: UILabel!
    @IBOutlet weak var nicknameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(forState state: (String, String)) {
        let stateName = state.0
        stateNameLabel.text = stateName
        if let image = UIImage(named: stateName.lowercased())?.resizeImage(CGSize(width: 62.0, height: 62.0)){
            stateImageView.image = image
            stateImageView.contentMode = UIViewContentMode.scaleAspectFit
        } else {
            stateImageView.image = UIImage(named: "NoImage")?.resizeImage(CGSize(width: 62.0, height: 62.0))
            stateImageView.contentMode = UIViewContentMode.scaleAspectFit
        }
        nicknameLabel.text = state.1
    }
    
    func configureCell(forHighway highway: String, stateAbbreviation: String, numberOfRestStops: Int){
        
        imageView?.image = nil
        stateNameLabel.text = ""
        nicknameLabel.text = ""
        stateNameLabel.text = highway.uppercased()
        nicknameLabel.text = String(numberOfRestStops) + " rest stops"
        imageView?.contentMode = UIViewContentMode.scaleAspectFit
//        if highway.contains("I-") || highway.contains("US-"){
//            if let image = UIImage(named: highway)?.resizeImage(CGSize(width: 62.0, height: 62.0)){
//                imageView?.image = image
//            } else {
//                imageView?.image = UIImage(named: "NoImage")?.resizeImage(CGSize(width: 62.0, height: 62.0))
//            }
//        } else {
//
//            if let image = UIImage(named: stateAbbreviation+"-"+highway)?.resizeImage(CGSize(width: 62.0, height: 62.0)){
//                imageView?.image = image
//            } else {
//                imageView?.image = UIImage(named: "NoImage")?.resizeImage(CGSize(width: 62.0, height: 62.0))
//            }
//        }
        
        if highway.contains("RT-"){
            
            let highwayNameComponents = highway.components(separatedBy: "-")
            
            if highwayNameComponents.count > 1 {
                let highwayName = "US-" + highwayNameComponents[1]
                if let image = UIImage(named: highwayName){
                    let resizedimage = image.resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
                    imageView?.image = resizedimage
                } else {
                    imageView?.image = #imageLiteral(resourceName: "NoImage").resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
                }
            } else {
                imageView?.image = #imageLiteral(resourceName: "NoImage").resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
            }
            
            if stateAbbreviation.uppercased() == "ME"{
                let highwayName = "ME-" + highway.uppercased()
                let image = UIImage(named: highwayName)!.resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
                imageView?.image = image
            }
            
            if stateAbbreviation.uppercased() == "MA"{
                let highwayName = "MA-" + highway.uppercased()
                let image = UIImage(named: highwayName)!.resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
                imageView?.image = image
            }
            
            if stateAbbreviation.uppercased() == "MI"{
                let highwayName = "MI-" + highway.uppercased()
                let image = UIImage(named: highwayName)!.resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
                imageView?.image = image
            }
            
            if stateAbbreviation.uppercased() == "CT"{
                let highwayName = "CT-" + highway.uppercased()
                let image = UIImage(named: highwayName)!.resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
                imageView?.image = image
            }
            
            
            
        } else {
            
            if let image = UIImage(named: highway){
                
                let resizedImage = image.resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
                imageView?.image = resizedImage
            } else {
                imageView?.image = #imageLiteral(resourceName: "NoImage").resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
            }
            
            if highway == "US-14A"{
                if let image = UIImage(named: "US-14"){
                    imageView?.image = image.resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
                } else {
                    imageView?.image = #imageLiteral(resourceName: "NoImage").resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
                }
            }
            
            
            if stateAbbreviation.uppercased() == "MN" && highway.contains("SR"){
                let highwayName = "MN-" + highway.uppercased()
                let image = UIImage(named: highwayName)!.resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
                imageView?.image = image
            }
            
            if stateAbbreviation.uppercased() == "MS" && highway.contains("SR"){
                let highwayName = "MS-" + highway.uppercased()
                let image = UIImage(named: highwayName)!.resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
                imageView?.image = image
            }
            
            if stateAbbreviation.uppercased() == "MO" && highway.contains("SR"){
                let highwayName = "MO-" + highway.uppercased()
                let image = UIImage(named: highwayName)!.resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
                imageView?.image = image
            }
            
            if stateAbbreviation.uppercased() == "MT" && highway.contains("MT"){
                let highwayName = "MT-" + highway.uppercased()
                let image = UIImage(named: highwayName)!.resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
                imageView?.image = image
            }
            
            if stateAbbreviation.uppercased() == "NE" && highway.contains("SR"){
                let highwayNameComponenets = highway.components(separatedBy: "-")
                if highwayNameComponenets.count > 1 {
                    let highwayName = "US-" + highwayNameComponenets[1]
                    let image = UIImage(named: highwayName)!.resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
                    imageView?.image = image
                } else {
                    imageView?.image = #imageLiteral(resourceName: "NoImage").resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
                }
            }
            
            if stateAbbreviation.uppercased() == "NV" && highway.contains("NV"){
                let highwayName = "NV-" + highway.uppercased()
                let image = UIImage(named: highwayName)!.resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
                imageView?.image = image
            }
            
            if stateAbbreviation.uppercased() == "WY" && highway.contains("SR"){
                let highwayName = "WY-" + highway.uppercased()
                let image = UIImage(named: highwayName)!.resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
                imageView?.image = image
            }
            if stateAbbreviation.uppercased() == "WA" && highway.contains("SR"){
                if highway == "SR-12"{
                    if let image = UIImage(named: "US-12"){
                        imageView?.image = image.resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
                    } else {
                        imageView?.image = #imageLiteral(resourceName: "NoImage").resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
                    }
                } else {
                    let highwayName = "WA-" + highway.uppercased()
                    let image = UIImage(named: highwayName)!.resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
                    imageView?.image = image
                }
                
            }
            
            if stateAbbreviation.uppercased() == "VT" && highway.contains("SR"){
                let highwayName = "VT-" + highway.uppercased()
                let image = UIImage(named: highwayName)!.resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
                imageView?.image = image
            }
            
            if stateAbbreviation.uppercased() == "UT" && highway.contains("SR"){
                let highwayName = "UT-" + highway.uppercased()
                let image = UIImage(named: highwayName)!.resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
                imageView?.image = image
            }
            
            if stateAbbreviation.uppercased() == "TX" && highway.contains("SR") {
                let highwayName = "TX-" + highway.uppercased()
                let image = UIImage(named: highwayName)!.resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
                imageView?.image = image
            }
            
            if stateAbbreviation.uppercased() == "TX" && highway.contains("RR") {
                let highwayName = "TX-" + highway.uppercased()
                let image = UIImage(named: highwayName)!.resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
                imageView?.image = image
            }
            
            if stateAbbreviation.uppercased() == "OR" && highway.contains("SR") {
                if highway != "SR-14" && highway != "SR-401"{
                    let highwayName = "OR-" + highway.uppercased()
                    let image = UIImage(named: highwayName)!.resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
                    imageView?.image = image
                } else {
                    imageView?.image = #imageLiteral(resourceName: "NoImage").resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
                }
                
            }
            
            if stateAbbreviation.uppercased() == "OK" && highway.contains("SR") {
                let highwayName = "OK-" + highway.uppercased()
                let image = UIImage(named: highwayName)!.resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
                imageView?.image = image
            }
            
            if stateAbbreviation.uppercased() == "OK" && highway.contains("H E BAILEY TP") {
                let highwayName = "OK-" + highway.uppercased()
                let image = UIImage(named: highwayName)!.resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
                imageView?.image = image
            }
            if stateAbbreviation.uppercased() == "OK" && highway.contains("INDIAN NATION TP") {
                let highwayName = "OK-" + highway.uppercased()
                let image = UIImage(named: highwayName)!.resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
                imageView?.image = image
            }
            
            if stateAbbreviation.uppercased() == "OK" && highway.contains("WILL ROGERS TP") {
                let highwayName = "OK-" + highway.uppercased()
                let image = UIImage(named: highwayName)!.resizeImage(CGSize(width: 62.0, height: 62.0)).withRenderingMode(.alwaysOriginal)
                imageView?.image = image
            }
            
        }
        
        
        
        backgroundColor = UIColor.clear
    }
}
