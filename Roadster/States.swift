//
//  StateAttributes.swift
//  Roadster
//
//  Created by A Ja on 9/7/16.
//  Copyright © 2016 A Ja. All rights reserved.
//

import Foundation
import CoreLocation
import Dispatch

class States {
    
    static let stateNamesAndNicknames: [(String, String)] = [("Alabama", "Heart of Dixie"), ("Alaska", "The Last Frontier"), ("Arizona", "Grand Canyon State"), ("Arkansas", "The Natural State"), ("California", "The Golden State"), ("Colorado", "Centennial State"), ("Connecticut", "The Constitution State"), ("Delaware", "The First State"), ("Florida", "The Sunshine State"), ("Georgia", "The Peach State"), ("Hawaii", "The Aloha State"), ("Idaho", "The Gem State"), ("Illinois", "The Prairie State"),("Indiana", "The Hoosier State"), ("Iowa", "The Hawkeye State"), ("Kansas", "The Sunflower State"), ("Kentucky", "The Bluegrass State"), ("Louisiana", "The Pelican State"), ("Maine", "The Vacationland"), ("Maryland", "The Old Line State"), ("Massachusetts", "The Bay State"), ("Michigan", "The Apple Blossom State"), ("Minnesota", "The Lake District"), ("Mississippi", "The Magnolia State"), ("Missouri", "Show-Me State"), ("Montana", "The Treasure State"), ("Nebraska", "The Cornhusker State"), ("Nevada", "The Silver State"), ("New Hampshire", "The Granite State"), ("New Jersey", "The Garden State"), ("New Mexico", "Land of Enchantment"), ("New York", "Empire State"), ("North Carolina", "Tar Heel State"), ("North Dakota", "Peace Garden State"), ("Ohio", "Buckeye State"), ("Oklahoma", "Sonner State"), ("Oregon", "Beaver State"), ("Pennsylvania", "Keystone State"), ("Rhode Island", "Ocean State"), ("South Carolina", "Palmetto State"), ("South Dakota", "The Mount Rushmore State"), ("Tennessee", "Volunteer State"), ("Texas", "Lone Star State"), ("Utah", "Beehive State"), ("Vermont", "Green Mountain State"), ("Virginia", "Mother of States"), ("Washington", "Evergreen State"), ("West Virginia", "Mountain State"), ("Wisconsin", "Forward State"), ("Wyoming", "Equality State")]
    
    static let abbreviationForState: [(String, String)] = [("Alabama", "AL"), ("Alaska", "AK"), ("Arizona", "AZ"), ("Arkansas", "AR"), ("California", "CA"), ("Colorado", "CO"), ("Connecticut", "CT"), ("Delaware", "DE"), ("Florida", "FL"), ("Georgia", "GA"), ("Hawaii", "HI"), ("Idaho", "ID"), ("Illinois", "IL"), ("Indiana", "IN"), ("Iowa", "IA"), ("Kansas", "KS"), ("Kentucky", "KY"), ("Louisiana", "LA"), ("Maine", "ME"), ("Maryland", "MD"), ("Massachusetts", "MA"), ("Michigan", "MI"), ("Minnesota", "MN"), ("Mississippi", "MS"), ("Missouri", "MO"), ("Montana", "MT"), ("Nebraska", "NE"), ("Nevada", "NV"), ("New Hampshire", "NH"), ("New Jersey", "NJ"), ("New Mexico", "NM"), ("New York", "NY"), ("North Carolina", "NC"), ("North Dakota", "ND"), ("Ohio", "OH"), ("Oklahoma", "OK"), ("Oregon", "OR"), ("Pennsylvania", "PA"), ("Rhode Island", "RI"), ("South Carolina", "SC"), ("South Dakota", "SD"), ("Tennessee", "TN"), ("Texas", "TX"), ("Utah", "UT"), ("Vermont", "VT"), ("Virginia", "VA"), ("Washington", "WA"), ("West Virginia", "WV"), ("Wisconsin", "WI"), ("Wyoming", "WY")]
    
    
     init(){
    }
    
    deinit{
        print("The state object has been deallocated!*******")
    }
    
    class func stateName(forIndex index: Int) -> String {
        return stateNamesAndNicknames[index].0
    }
    
    class func stateNickname(forIndex index: Int) -> String{
        return stateNamesAndNicknames[index].1
    }
    
    class func numberOfStates() -> Int{
        return stateNamesAndNicknames.count
    }
    
    class func stateNamesAndNicknamesElement(forIndex index: Int) -> (String, String){
        return stateNamesAndNicknames[index]
    }
    
    class func stateNamesAndNicknamesDictionary() -> [(String, String)] {
        return stateNamesAndNicknames
    }
    
    class func abbreviation(for state: String) -> String{
        var abbreviationString: String!
        for abbreviation in abbreviationForState{
            if abbreviation.0 == state{
                abbreviationString = abbreviation.1
                break
            } else {
                abbreviationString = "No state found"
            }
        }
        return abbreviationString
    }
    
    class func getFullStateName(for abbreviation: String) -> String? {
        var fullStateName: String? = ""
        
        for fullName in abbreviationForState{
            if fullName.1 == abbreviation{
                fullStateName = fullName.0
            }
        }
        
        return fullStateName
    }
    
}

