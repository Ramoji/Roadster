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
import Dispatch
import SwiftyJSON
import AlamofireImage

struct APIURLs {
    
    static let baseURL = "http://localhost:8080"
    static let registerURL = "http://localhost:8080/register"
    static let signinURL = "http://localhost:8080/signin"
    static let postCommentURL = "http://localhost:8080/postComment"
    static let usernameUniqueness = "http://localhost:8080/usernameUniqueness"
    static let logout = "http://localhost:8080/logout"
}

struct Comment {
    var latitude: Double
    var longitude: Double
    var email: String
    var username: String
    var comment: String
    var date: String
    var rating: Double
}

struct APIErrorMessages {
    static let invalidCredentials = "invalidCredentials"
    static let emailExists = "emailExists"
    static let userExists = "userExists"
    static let networkError = "networkError"
    static let userNotFound = "userNotFound"
}


class HTTPHelper{
    
    
    static let cypherHelper = CypherHelper()

    
    
    class func registerUser(name: String, lastname: String, username: String, email: String, password: String, apiCallCompleted: @escaping (_ complete: Bool, _ errorMessage: String?)->()){
        let encryptedPassword = cypherHelper.encrypt(string: password)
        let parameters: Parameters = [
            "name": name.lowercased(),
            "lastname":lastname.lowercased(),
            "username": username.lowercased(),
            "email": email.lowercased(),
            "password": encryptedPassword
        ]
        
        var headers: HTTPHeaders = [:]
        
        if let authorizationHeader = Request.authorizationHeader(user: APICredentials.encryptedAPI_USERNAME, password: APICredentials.encryptedAPI_KEY){
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        
        Alamofire.request(APIURLs.registerURL, method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON{ response in
            
            switch response.result{
            case .success:
                //Do JSON parsing and return true to the closure
                
                var responseDictionary: [String: AnyObject] = [:]
                do {
                    
                    responseDictionary = try JSONSerialization.jsonObject(with: Data(bytes:response.data!.bytes), options: .allowFragments) as! [String: AnyObject]
                    
                } catch let error as NSError {
                    print("Failed to parse JSON response: \(error.debugDescription)")
                }
                
                if let _ = responseDictionary["error"] {
                    
                    switch responseDictionary["message"]! as! String{
                    case APIErrorMessages.emailExists:
                        apiCallCompleted(true, APIErrorMessages.emailExists)
                        break
                    case APIErrorMessages.userExists:
                        apiCallCompleted(true, APIErrorMessages.userExists)
                        break
                    default:
                        apiCallCompleted(true, APIErrorMessages.invalidCredentials)
                    }
                } else {
                    apiCallCompleted(true, nil)
                    CypherHelper.saveAccessToken(
                        forUserEmail: responseDictionary["email"]! as! String,
                        andToken: responseDictionary["accessToken"]! as! String,
                        withExpiryDate: responseDictionary["expiryDate"]! as! String)
                }
                break
            case .failure:
                apiCallCompleted(false, APIErrorMessages.networkError)
                break
            }
        }
    }
    
    class func signinUser(email: String, password: String, requestComplete: @escaping (_ completed: Bool, _ httpErrorMessage: String?) -> ()){
        
        var headers: HTTPHeaders = [:]
        let encryptedPassword = cypherHelper.encrypt(string: password)
        print(encryptedPassword)
        if let authorizationHeader = Request.authorizationHeader(user: email, password: encryptedPassword){
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        
        Alamofire.request(APIURLs.signinURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{ response in
            
            switch response.result{
            case .success: //http request went through but there might be http errors involved
                var responseDictionary: [String: AnyObject] = [:]
                
                do{
                    responseDictionary = try JSONSerialization.jsonObject(with: Data(bytes: response.data!.bytes), options: JSONSerialization.ReadingOptions.allowFragments) as! [String: AnyObject]
                } catch let error as NSError {
                    print("Failed to parse JSON response: \(error.debugDescription)")
                }
                
                if let _ = responseDictionary["error"]{
                    switch responseDictionary["message"]! as! String{
                    case APIErrorMessages.userNotFound:
                        requestComplete(true, APIErrorMessages.userNotFound)
                        break
                    default:
                        requestComplete(true, APIErrorMessages.invalidCredentials)
                    }
                } else {
                    requestComplete(true, nil)
                    CypherHelper.saveAccessToken(forUserEmail: responseDictionary["email"]! as! String, andToken: responseDictionary["accessToken"]! as! String, withExpiryDate: responseDictionary["expiryDate"]! as! String)
                }
                
                break
            case .failure: //http request did not go through at all because of variety of reasons
                    requestComplete(false, APIErrorMessages.networkError)
                break
            }
        }
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
                    let comment = Comment(
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
    
    class func checkUsernameUniqueness(username: String, completedCheck:@escaping (_ completed: Bool,_ httpErrorMessage:String?)->()){
        
        var headers: HTTPHeaders = [:]
        
        let encryptedUsername = cypherHelper.encrypt(string: username)
        
        headers["username"] = encryptedUsername
        
        if let authorizationHeader = Request.authorizationHeader(user: APICredentials.encryptedAPI_USERNAME, password: APICredentials.encryptedAPI_KEY){
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        
        Alamofire.request(APIURLs.usernameUniqueness, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{response in
            
            switch response.result{
            case .success:
                var responseDictionary: [String: AnyObject] = [:]
                do {
                    
                    responseDictionary = try JSONSerialization.jsonObject(with: Data(bytes:response.data!.bytes), options: .allowFragments) as! [String: AnyObject]
                    
                } catch let error as NSError {
                    print("Failed to parse JSON response: \(error.debugDescription)")
                }
                
                if let _ = responseDictionary["error"] {
                    if responseDictionary["message"]! as! String == APIErrorMessages.userExists{
                        completedCheck(true, APIErrorMessages.userExists)
                    }
                } else {
                    completedCheck(true, nil)
                }
                break
            case .failure:
                completedCheck(false, nil)
                break
            }
        }
    }
    
    class func logout(){
        var headers: HTTPHeaders = [:]
        if let authorizationHeader = Request.authorizationHeader(user: APICredentials.encryptedAPI_USERNAME, password: APICredentials.encryptedAPI_KEY){
            headers[authorizationHeader.key] = authorizationHeader.value
        }
        
        headers["email"] = UserDefaults.standard.object(forKey: DefaultKeys.currentUserEmail) as? String
        
        Alamofire.request(APIURLs.logout, method: .delete, parameters: nil, encoding: JSONEncoding.default, headers: headers).response{response in
        }
        CypherHelper.deleteAccessToken()
    }
    
    class func getYelpComments(for businessID: String, completionHandlers: @escaping (_ data: Data) -> ()){
        
        checkYelpAccessTokenValidityAndExecute{ yelpToken in
            
            let commentURL = "https://api.yelp.com/v3/businesses/\(businessID)/reviews"
            let headers: HTTPHeaders = ["Authorization": "Bearer \(yelpToken)"]
            Alamofire.request(commentURL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: headers).responseJSON{ response in
                
                if response.response?.statusCode == 200{
                    if let data = response.data{
                    
                        completionHandlers(data)
                        
                    }
                }
            }
        }
    }
    
    class func checkYelpAccessTokenValidityAndExecute(block: @escaping (_ yelpToken: String) -> ()){
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .full
        
        
        if let dateString = UserDefaults.standard.string(forKey: DefaultKeys.yelpAccessTokenExpiryDate) {
            
            let tokenExpiryDate = dateFormatter.date(from: dateString)!
            
            if tokenExpiryDate.timeIntervalSinceNow < -15552000{
                
                let parameters: Parameters = ["grant_type": "client_credentials", "client_id": APICredentials.yelpAPI_ID, "client_secret": APICredentials.yelpAPI_secret]
                
                Alamofire.request("https://api.yelp.com/oauth2/token", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON{ response in
                    
                    
                    do{
                        let jsonObj = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as! [String: AnyObject]
                        UserDefaults.standard.set(jsonObj["access_token"] as! String, forKey: DefaultKeys.yelpAccessToken)
                        UserDefaults.standard.set(dateFormatter.string(from: Date()), forKey: DefaultKeys.yelpAccessTokenExpiryDate)
                    } catch let error as NSError{
                        print(error.debugDescription)
                        print(error.localizedDescription)
                    }
                    
                    block(UserDefaults.standard.object(forKey: DefaultKeys.yelpAccessToken)! as! String)
                }
                
            } else {
                
                    block(UserDefaults.standard.object(forKey: DefaultKeys.yelpAccessToken)! as! String)
                
            }
            
            
        } else {
            
            let parameters: Parameters = ["grant_type": "client_credentials", "client_id": APICredentials.yelpAPI_ID, "client_secret": APICredentials.yelpAPI_secret]
            
            Alamofire.request("https://api.yelp.com/oauth2/token", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: nil).responseJSON{ response in
                
                
                do{
                    let jsonObj = try JSONSerialization.jsonObject(with: response.data!, options: .allowFragments) as! [String: AnyObject]
                    UserDefaults.standard.set(jsonObj["access_token"] as! String, forKey: DefaultKeys.yelpAccessToken)
                    UserDefaults.standard.set(dateFormatter.string(from: Date()), forKey: DefaultKeys.yelpAccessTokenExpiryDate)
                } catch let error as NSError{
                    print(error.debugDescription)
                    print(error.localizedDescription)
                }
                
                
                block(UserDefaults.standard.object(forKey: DefaultKeys.yelpAccessToken)! as! String)
            }
        }
    }
    
    class func getImage(from url: String, completionHandler: @escaping (_ image: UIImage) -> ()){
        var downloadedImage: UIImage = #imageLiteral(resourceName: "NoImage")
        Alamofire.request(url).responseImage{response in
            if let image = response.result.value{
                downloadedImage = image
                completionHandler(downloadedImage)
            }
        }
    }
    
    class func sendEmail(recepient: String, sender: String, subject: String, emailBody: String){
        
        let basicAuthentication = Request.authorizationHeader(user: "api", password: "key-619c0bfe2549ae5067cfc4b3db6a2bcd")
        
        let headers: HTTPHeaders = [(basicAuthentication?.key)!: (basicAuthentication?.value)!]
        let parameters: Parameters? = ["from": "Heather Larson<mailgun@sandbox590f92129f0449539d99dda52ed1f197.mailgun.org>",
                                       "to": recepient,
                                       "subject": subject,
                                       "text": emailBody]
        
        
        Alamofire.request("https://api.mailgun.net/v3/sandbox590f92129f0449539d99dda52ed1f197.mailgun.org/messages", method: .post, parameters: parameters, encoding: URLEncoding.default, headers: headers).responseJSON{ response in
            
            print(response)
            
        }
    
    }
}
