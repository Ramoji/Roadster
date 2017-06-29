//
//  SignUpViewController.swift
//  Roadster
//
//  Created by EA JA on 5/22/17.
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastnameTextField: UITextField!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var square: UIView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var requiredFieldsAlertLabel: UILabel!
    @IBOutlet weak var validEmailAddressAlertLabel: UILabel!
    @IBOutlet weak var passwordLengthRequirementAlertLabel: UILabel!
    @IBOutlet weak var usernameTakenAlertLable: UILabel!
    

    
    var labelArray: [UITextField]!

    override var prefersStatusBarHidden: Bool{
        get{return true}
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func loadView() {
        super.loadView()
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    
    @IBAction func next(_ sender: UIButton) {
        
        guard areAllFieldsWrittenTo() else {
            
        
            animate(alertBanner: requiredFieldsAlertLabel)
            
            return
        }
        
        guard emailTextField.text!.contains("@") else {
            animate(alertBanner: validEmailAddressAlertLabel)
            return
        }
        
        guard passwordTextField.text!.characters.count >= 6 else {
            animate(alertBanner: passwordLengthRequirementAlertLabel)
            return
        }
        
        HTTPHelper.checkUsernameUniqueness(username: usernameTextField.text!){
            completed, error in
            guard completed else {
                let alert = UIAlertController(title: "Network Error", message: "There was a network error while processing your request. Please try again later.", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default){ action in
                    self.dismiss(animated: true, completion: nil)
                }
                alert.addAction(alertAction)
                self.present(alert, animated: true, completion: nil)
                return
            }
            
            if let _ = error{
                self.animate(alertBanner: self.usernameTakenAlertLable)
            } else {
                self.performSegue(withIdentifier: "confirmEmail", sender: sender)
            }
        }
    }
    @IBAction func cancel(_ sender: UIButton) {
        requiredFieldsAlertLabel.isHidden = true
        passwordLengthRequirementAlertLabel.isHidden = true
        validEmailAddressAlertLabel.isHidden = true
        dismiss(animated: true, completion: nil)
    }
    
    func areAllFieldsWrittenTo() -> Bool{
        if firstNameTextField.text!.isEmpty || lastnameTextField.text!.isEmpty || usernameTextField.text!.isEmpty || emailTextField.text!.isEmpty || passwordTextField.text!.isEmpty {
            return false
        } else {return true}
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "confirmEmail"{
            let confirmEmailViewController = segue.destination as! ConfirmEmailViewController
            confirmEmailViewController.firstName = firstNameTextField.text!
            confirmEmailViewController.lastname = lastnameTextField.text!
            confirmEmailViewController.username = usernameTextField.text!
            confirmEmailViewController.email = emailTextField.text!
            confirmEmailViewController.password = passwordTextField.text!
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
    
    @IBAction func signIn(_ sender: UIButton) {
        let signInViewController = storyboard?.instantiateViewController(withIdentifier: "signInViewController")
        present(signInViewController!, animated: true, completion: nil)
    }
}
