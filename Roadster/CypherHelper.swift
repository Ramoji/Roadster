
//  Copyright © 2017 A Ja. All rights reserved.
//

import Foundation
import CryptoSwift
import SwiftKeychainWrapper

struct APICredentials {
    static let API_KEY = ""
    static let encryptedAPI_KEY = ""
    static let API_USERNAME = "" //Username to access the API through basic auth!
    static let encryptedAPI_USERNAME = ""
    static let API_IV = "" // Used in conjunction with API_KEY to encode
    static let yelpAPI_ID = ""
    static let yelpAPI_secret = ""
    static let mailGunTempDomain = ""
    static let mailGunAPIUsername = ""
    static let mailGunAPIPassword = ""
    static let mailGunSendEmailAPIEndPointURL = ""
    static let developerEmailAddress = ""
}

struct DefaultKeys {
    static let signedIn = "signedIn"
    static let firstName = "firstname"
    static let lastName = "lastname"
    static let currentUserEmail = "currentUserEmail"
    static let currentUsername = "currentUsername"
    static let yelpAccessToken = "yelpAccessToken"
    static let yelpAccessTokenExpiryDate = "yelpAccessTokenExpireyDate"
}

struct KeychainKeys {
    static let expiryDate = "expiryDate"
    static let currentUserToken = "currentUserToken"
}

struct KeyedArchiverKeys {
    static let favoriteBusinessesListKey: String = "favoriteBusinesses"
    static let favoriteLocationsListKey: String = "favoriteLocations"
}

class CypherHelper{
    

    let aesCypher: AES
    static let defaults = UserDefaults.standard
    
    init(){
        do {
            aesCypher = try AES(key: APICredentials.API_KEY, iv: APICredentials.API_IV)
        } catch {
            fatalError("Failed to initiate an instance of CypherHelper.")
        }
    }
    
    func encrypt(string: String) -> String {
        let encryptedString: String?
        do{
            encryptedString = try aesCypher.encrypt(Array(string.utf8)).toHexString()
        }catch{
            fatalError("Failed to encrypt string in CypherHelper")
        }
        return encryptedString!
    }
    
    class func saveAccessToken(forFirstName firstName: String, lastName: String, userEmail: String, username: String, andToken token: String, withExpiryDate expiryDate: String){
        KeychainWrapper.standard.set(token, forKey: KeychainKeys.currentUserToken)
        KeychainWrapper.standard.set(expiryDate, forKey: KeychainKeys.expiryDate)
        defaults.set(true, forKey: DefaultKeys.signedIn)
        defaults.set(firstName, forKey: DefaultKeys.firstName)
        defaults.set(lastName, forKey: DefaultKeys.lastName)
        defaults.set(userEmail, forKey: DefaultKeys.currentUserEmail)
        defaults.set(username, forKey: DefaultKeys.currentUsername)
        defaults.synchronize()
    }
    
    class func deleteAccessToken(){
        KeychainWrapper.standard.removeObject(forKey: KeychainKeys.currentUserToken)
        KeychainWrapper.standard.removeObject(forKey: KeychainKeys.expiryDate)
        defaults.set(false, forKey: DefaultKeys.signedIn)
        defaults.removeObject(forKey: DefaultKeys.currentUserEmail)
        defaults.removeObject(forKey: DefaultKeys.currentUsername)
        defaults.removeObject(forKey: DefaultKeys.lastName)
        defaults.removeObject(forKey: DefaultKeys.firstName)
        defaults.synchronize()
    }

}
