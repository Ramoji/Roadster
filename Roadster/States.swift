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
    
    let stateNamesAndNicknames: [(String, String)] = [("Alabama", "Heart of Dixie"), ("Alaska", "The Last Frontier"), ("Arizona", "Grand Canyon State"), ("Arkansas", "The Natural State"), ("California", "The Golden State"), ("Colorado", "Centennial State"), ("Connecticut", "The Constitution State"), ("Delaware", "The First State"), ("District of Columbia", "Nation's Capital"), ("Florida", "The Sunshine State"), ("Georgia", "The Peach State"), ("Hawaii", "The Aloha State"), ("Idaho", "The Gem State"), ("Illinois", "The Prairie State"),("Indiana", "The Hoosier State"), ("Iowa", "The Hawkeye State"), ("Kansas", "The Sunflower State"), ("Kentucky", "The Bluegrass State"), ("Louisiana", "The Pelican State"), ("Maine", "The Vacationland"), ("Maryland", "The Old Line State"), ("Massachusetts", "The Bay State"), ("Michigan", "The Apple Blossom State"), ("Minnesota", "The Lake District"), ("Mississippi", "The Magnolia State"), ("Missouri", "Show-Me State"), ("Montana", "The Treasure State"), ("Nebraska", "The Cornhusker State"), ("Nevada", "The Silver State"), ("New Hampshire", "The Granite State"), ("New Jersey", "The Garden State"), ("New Mexico", "Land of Enchantment"), ("New York", "Empire State"), ("North Carolina", "Tar Heel State"), ("North Dakota", "Peace Garden State"), ("Ohio", "Buckeye State"), ("Oklahoma", "Sonner State"), ("Oregon", "Beaver State"), ("Pennsylvania", "Keystone State"), ("Rhode Island", "Ocean State"), ("South Carolina", "Palmetto State"), ("South Dakota", "The Mount Rushmore State"), ("Tennessee", "Volunteer State"), ("Texas", "Lone Star State"), ("Utah", "Beehive State"), ("Vermont", "Green Mountain State"), ("Virginia", "Mother of States"), ("Washington", "Evergreen State"), ("West Virginia", "Mountain State"), ("Wisconsin", "Forward State"), ("Wyoming", "Equality State")]
    
    let abbreviationForState: [String: String] = ["Alabama": "AL", "Alaska": "AK", "Arizona": "AZ", "Arkansas": "AR", "California": "CA", "Colorado": "CO", "Connecticut": "CT", "Delaware": "DE", "District of Columbia": "", "Florida": "FL", "Georgia": "GA", "Hawaii": "HI", "Idaho": "ID", "Illinois": "IL", "Indiana": "IN", "Iowa": "IA", "Kansas": "KS", "Kentucky": "KY", "Louisiana": "LA", "Maine": "ME", "Maryland": "MD", "Massachusetts": "MA", "Michigan": "MI", "Minnesota": "MN", "Mississippi": "MS", "Missouri": "MO", "Montana": "MT", "Nebraska": "NE", "Nevada": "NV", "New Hampshire": "NH", "New Jersey": "NJ", "New Mexico": "NM", "New York": "NY", "North Carolina": "NC", "North Dakota": "ND", "Ohio": "OH", "Oklahoma": "OK", "Oregon": "OR", "Pennsylvania": "PA", "Rhode Island": "RI", "South Carolina": "SC", "South Dakota": "SD", "Tennessee": "TN", "Texas": "TX", "Utah": "UT", "Vermont": "VT", "Virginia": "VA", "Washington": "WA", "West Virginia": "WV", "Wisconsin": "WI", "Wyoming": "WY"]
    
    
    let statesCenteredLocations: [String: (Double, Double)] = [ "Alabama": (32.7784, -86.929), "Alaska": (64.061, -152.2307), "California": (37.1992, -119.4505)]
    let statesCenteredLocationsSpan: [String: (Double, Double)] = ["Alabama": (550000, 550000), "Alaska": (2000000, 200000), "California": (500000, 200000 )]
    
     init(){
    }
    
    deinit{
        print("The state object has been deallocated!*******")
    }
    
    func stateName(forIndex index: Int) -> String {
        return stateNamesAndNicknames[index].0
    }
    
    func stateNickname(forIndex index: Int) -> String{
        return stateNamesAndNicknames[index].1
    }
    
    func numberOfStates() -> Int{
        return stateNamesAndNicknames.count
    }
    
    func stateNamesAndNicknamesElement(forIndex index: Int) -> (String, String){
        return stateNamesAndNicknames[index]
    }
    
    func stateGeographicCenter(forState state: String) -> CLLocationCoordinate2D{
        let coordinates = statesCenteredLocations[state]
        let location = CLLocationCoordinate2D(latitude: coordinates!.0, longitude: coordinates!.1)
        return location
    }
    
    func stateNamesAndNicknamesDictionary() -> [(String, String)] {
        return stateNamesAndNicknames
    }
    
    func stateCenteredLocationSpanInMeters(forState state: String) -> (Double, Double) {
        return statesCenteredLocationsSpan[state]!
    }
    
    func abbreviation(for state: String) -> String{
        if let state = abbreviationForState[state]{
            return state
        } else {
            return "No state found"
        }
    }
    
}

