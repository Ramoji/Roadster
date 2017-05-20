//
//  CypherHelper.swift
//  Roadster
//
//  Created by EA JA on 5/15/17.
//  Copyright © 2017 A Ja. All rights reserved.
//

import Foundation
import CryptoSwift

struct APICredentials {
    static let API_KEY = "H#4hfgsy4783dget"
    static let encryptedAPI_KEY = "25a2cbab9fbf5873cbde4c56d526fac68a54f3bb871ca26f2072545458269ff5"
    static let API_USERNAME = "bOOKERtHEcORGI" //Username to access the API through basic auth!
    static let encryptedAPI_USERNAME = "ced5e1548ab8332b2919aa4228e2b1a8"
    static let API_IV = "rerekooBrerekooB" // Used in conjunction with API_KEY to encode
}

class CypherHelper{
    

    let aesCypher: AES
    
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

}
