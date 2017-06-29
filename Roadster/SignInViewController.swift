//
//  SignInViewController.swift
//  Roadster
//
//  Created by EA JA on 5/24/17.
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var invalidEmailPasswordAlert: UILabel!
    let cypherHelper = CypherHelper()
    
    override var prefersStatusBarHidden: Bool{
        get{return true}
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        toggleSignInButton(isEnabled: false)
        emailTextField.addTarget(self, action: #selector(textFieldsDidChangeText), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFieldsDidChangeText), for: .editingChanged)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func signIn(_ sender: UIButton){
        
        HTTPHelper.signinUser(email: emailTextField.text!, password: passwordTextField.text!){completed, error in
            
            guard completed else {
                let alert = UIAlertController(title: "Network Error", message: "There was a network error while processing your request. Please try again later.", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default){ action in
                    self.dismiss(animated: true, completion: nil)
                }
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            if let _ = error {
                switch error!{
                case APIErrorMessages.userNotFound:
                    self.animate(alertBanner: self.invalidEmailPasswordAlert)
                    break
                default:
                    print("Invalid credentials.")
                }
            } else {
                self.dismiss(animated: true, completion: nil)
            }
        }
        
    }
    
    @IBAction func cancel(_ sender: UIButton){
        dismiss(animated: true, completion: nil)
    }
    
    func textFieldsDidChangeText() {
        print("In target method!")
        if emailTextField.text != "" && passwordTextField.text != ""{
            toggleSignInButton(isEnabled: true)
        } else {
            toggleSignInButton(isEnabled: false)
        }
        
    }

    
    func toggleSignInButton(isEnabled: Bool){
        if isEnabled{
            signInButton.isEnabled = isEnabled
            signInButton.backgroundColor = UIColor(red: 0, green: 122/256, blue: 255/256, alpha: 1.0)
        } else {
            signInButton.isEnabled = isEnabled
            signInButton.backgroundColor = UIColor(red: 0, green: 122/256, blue: 255/256, alpha: 0.5)
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
    
    @IBAction func forgotPassword(_ sender: UIButton){
        performSegue(withIdentifier: "passwordRecovery", sender: sender)
        
    }
}
