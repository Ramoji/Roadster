//
//  ConfirmEmailViewController.swift
//  Roadster
//
//  Created by EA JA on 5/22/17.
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit
import Dispatch

protocol ConfirmEmailViewControllerDelegate: class {
    func confirmEmailViewControllerWillDeallocate(_ confirmEmailViewController: ConfirmEmailViewController)
}

class ConfirmEmailViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var emailAddressesDoNotMatchAlertLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var anErrorOccuredTryAgainAlertLabel: UILabel!
    
    var originalPresenter: AnyObject!

    
    override var prefersStatusBarHidden: Bool{
        get {
            return true
        }
    }
    
    var firstName: String!
    var lastname: String!
    var username: String!
    var email: String!
    var password: String!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        signUpButton.isEnabled = false
        signUpButton.backgroundColor = UIColor(red: 0, green: 122/256, blue: 255/256, alpha: 0.5)
        emailTextField.addTarget(self, action: #selector(emailTextFieldDidChangeText), for: UIControlEvents.editingChanged)
        activityIndicator.isHidden = true
        
    }

    @IBAction func signUp(_ sender: UIButton) {
        
        guard email == emailTextField.text! else {
            animate(alertBanner: emailAddressesDoNotMatchAlertLabel)
            return
        }
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        HTTPHelper.registerUser(
            name: firstName.lowercased(),
            lastname: lastname.lowercased(),
            username: username.lowercased(),
            email: email.lowercased(), password: password){ completed, error in
                
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.isHidden = true
                    self.view.setNeedsLayout()
                }
                
                guard completed else {
                    let alert = UIAlertController(title: "Network Error", message: "There was a network error while processing your request. Please try again later.", preferredStyle: .alert)
                    let alertAction = UIAlertAction(title: "OK", style: .default){ action in
                        self.dismiss(animated: true, completion: nil)
                    }
                    alert.addAction(alertAction)
                    self.present(alert, animated: true, completion: nil)
                    return
                }
                
                if let error = error{
                    switch error{
                    case APIErrorMessages.emailExists:
                        let alert = UIAlertController(title: "Exisitng Account", message: "The email address you entered is already associated with an account. Please use it to sign in.", preferredStyle: .alert)
                        let alertAction = UIAlertAction(title: "OK", style: .default){action in
                            self.dismiss(animated: true, completion: nil)
                        }
                        alert.addAction(alertAction)
                        self.present(alert, animated: true, completion: nil)
                        break
                    case APIErrorMessages.userExists:
                        //Already handled in the previous view
                        break
                    default:
                        self.animate(alertBanner: self.anErrorOccuredTryAgainAlertLabel)
                    }
                } else {
                    
                    if let _ = self.originalPresenter as? StaticDetailTableViewController{
                        
                        self.performSegue(withIdentifier: "unwindToStaticDetailTableViewController", sender: self)
                        
                    } else if let _ = self.originalPresenter as? AddressTableViewController{
                        
                        self.performSegue(withIdentifier: "unwindToAddressTableViewController", sender: self)
                    }
                    
                }
            }
    }
    
    @IBAction func back(_ sender: UIButton){
        dismiss(animated: true, completion: nil)
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    func emailTextFieldDidChangeText(){
        if emailTextField.text != "" && emailTextField.text != " "{
            signUpButton.backgroundColor = UIColor(red: 0, green: 122/256, blue: 255/256, alpha: 1.0)
            signUpButton.isEnabled = true
        } else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = UIColor(red: 0, green: 122/256, blue: 255/256, alpha: 0.5)
        }
    }

    
    func animate(alertBanner banner: UILabel){
        
        banner.isHidden = false
        
        UIView.animateKeyframes(withDuration: 2.0, delay: 0, options: .calculationModeLinear, animations: {
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.05, animations: {
                banner.center.y = 15
            })
            UIView.addKeyframe(withRelativeStartTime: 0.06, relativeDuration: 0.94, animations: {
                
            })
            UIView.addKeyframe(withRelativeStartTime: 0.95, relativeDuration: 1.0, animations: {
                banner.center.y = -15
                
            })
        }, completion: nil)
    }


}


