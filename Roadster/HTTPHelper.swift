//
//  HTTPHelper.swift
//  Roadster
//
//  Created by EA JA on 5/13/17.
//  Copyright © 2017 A Ja. All rights reserved.
//

import Foundation
import Alamofire
import CryptoSwift

struct APIURLs {
    
    static let baseURL = "http://localhost:8080"
    static let registerURL = "http://localhost:8080/register"
    static let signinURL = "http://localhost:8080/signin"
    static let postCommentURL = "http://localhost:8080/postComment"
}

struct Comment {
    var key: Int
    var latitude: Double
    var longitude: Double
    var email: String
    var username: String
    var comment: String
    var date: String
    var rating: Double
}


class HTTPHelper{
    
    
    static let cypherHelper = CypherHelper()
    
    
    class func registerUser(name: String, lastname: String, username: String, email: String, password: String){
        let encryptedPassword = cypherHelper.encrypt(string: password)
        let lowercasedUsername = username.lowercased()
        let parameters: Parameters = [
            "name": name,
            "lastname":lastname,
            "username": lowercasedUsername,
            "email": email,
            "password": encryptedPassword
        ]
        
        var headers: HTTPHeaders = [:]
        
        if let authorizationHeader = Request.authorizationHeader(user: APICredentials.encryptedAPI_USERNAME, password: APICredentials.encryptedAPI_KEY){
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        
        Alamofire.request(APIURLs.registerURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON{ response in
            print(response)
        }
        
    }
    
    class func signinUser(email: String, password: String) -> [String: String] {
        var sessionInfo: [String: String] = [:]
        var headers: HTTPHeaders = [:]
        let encryptedPassword = cypherHelper.encrypt(string: password)
        if let authorizationHeader = Request.authorizationHeader(user: email, password: encryptedPassword){
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        
        Alamofire.request(APIURLs.signinURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{ response in
            print(response)
        }
        
        return sessionInfo
        
    }
    
    class func getComments(restStop: USRestStop, reloadTableViewClosure: @escaping (_ comments: [Comment])->()){
        
        var commentArray: [Comment] = []
        
        let parameters: Parameters = ["latitude": "-88.393032", "longitude": "30.477238"]
        var headers: HTTPHeaders = [:]
        
        if let authorizationHeader = Request.authorizationHeader(user: APICredentials.encryptedAPI_USERNAME, password: APICredentials.encryptedAPI_KEY){
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        
        Alamofire.request("http://localhost:8080/getComments", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON{
            response in
            let jsonData = Data(bytes: (response.data?.bytes)!)
            do{
                let jsonObjects = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as! [AnyObject]
                for jsonObject in jsonObjects{
                    print(jsonObject)
                    let publicComment = jsonObject as! [String: AnyObject]
                    let comment = Comment(key: publicComment["key"]! as! Int,
                                          latitude: publicComment["latitude"]! as! Double,
                                          longitude: publicComment["longitude"]! as! Double,
                                          email: publicComment["email"]! as! String,
                                          username: publicComment["username"]! as! String,
                                          comment: publicComment["comment"]! as! String,
                                          date: publicComment["date"]! as! String,
                                          rating: publicComment["rating"]! as! Double)
                    commentArray.append(comment)
                }
                reloadTableViewClosure(commentArray)
            }catch{
                print("Failed to parse comment json response!")
            }
        }
        
    }
    
    class func postComment(comment: Comment, userEmail: String, accessToken: String){
        let parameters: Parameters = [
            "key": String(comment.key),
            "latitude": String(comment.latitude),
            "longitude": String(comment.longitude),
            "email": comment.email,
            "username": comment.username,
            "comment": comment.comment,
            "date": comment.date,
            "rating": String(comment.rating)
        ]
        
        var headers: HTTPHeaders = [:]
        
        if let authorizationHeader = Request.authorizationHeader(user: userEmail, password: accessToken){
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        
        Alamofire.request(APIURLs.postCommentURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).response{ response in
            if response.error != nil{
                print("There was an error posting comment")
            }
        }
        
        
    }
    
}
