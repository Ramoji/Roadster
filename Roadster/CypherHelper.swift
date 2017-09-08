//
//  CypherHelper.swift
//  Roadster
//
//  Created by EA JA on 5/15/17.
//  Copyright © 2017 A Ja. All rights reserved.
//

import Foundation
import CryptoSwift
import SwiftKeychainWrapper

struct APICredentials {
    static let API_KEY = "H#4hfgsy4783dget"
    static let encryptedAPI_KEY = "25a2cbab9fbf5873cbde4c56d526fac68a54f3bb871ca26f2072545458269ff5"
    static let API_USERNAME = "bOOKERtHEcORGI" //Username to access the API through basic auth!
    static let encryptedAPI_USERNAME = "ced5e1548ab8332b2919aa4228e2b1a8"
    static let API_IV = "rerekooBrerekooB" // Used in conjunction with API_KEY to encode
    static let yelpAPI_ID = "F9jmXf_AL6xCSqDUA0qrJA"
    static let yelpAPI_secret = "5M4FdJC4hEGsl0XSXSETty7xluz8APQh05rP6HioeuNvoEcwllMKOCrHKFPvCFuh"
}

struct DefaultKeys {
    static let signedIn = "signedIn"
    static let currentUserEmail = "currentUserEmail"
    static let currentUsername = "currentUsername"
    static let yelpAccessToken = "yelpAccessToken"
    static let yelpAccessTokenExpiryDate = "yelpAccessTokenExpireyDate"
}

struct KeychainKeys {
    static let expiryDate = "expiryDate"
    static let currentUserToken = "currentUserToken"
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
    
    class func saveAccessToken(forUserEmail userEmail: String, username: String, andToken token: String, withExpiryDate expiryDate: String){
        KeychainWrapper.standard.set(token, forKey: KeychainKeys.currentUserToken)
        KeychainWrapper.standard.set(expiryDate, forKey: KeychainKeys.expiryDate)
        defaults.set(true, forKey: DefaultKeys.signedIn)
        defaults.set(userEmail, forKey: DefaultKeys.currentUserEmail)
        defaults.set(username, forKey: DefaultKeys.currentUsername)
        defaults.synchronize()
    }
    
    class func deleteAccessToken(){
        KeychainWrapper.standard.removeObject(forKey: KeychainKeys.currentUserToken)
        KeychainWrapper.standard.removeObject(forKey: KeychainKeys.expiryDate)
        defaults.set(false, forKey: DefaultKeys.signedIn)
        defaults.removeObject(forKey: DefaultKeys.currentUserEmail)
        defaults.synchronize()
    }

}
