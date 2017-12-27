
//  Copyright © 2017 A Ja. All rights reserved.
//

import UIKit

class PasswordRecoveryViewController: UIViewController {
    
    @IBOutlet weak var emailAddressTextField: UITextField!
    @IBOutlet weak var recoveryButton: UIButton!
    var unwindDestinationViewController: UIViewController!
    override var prefersStatusBarHidden: Bool{
        get{return true}
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        toggleRecoveryInButton(isEnabled: false)
        emailAddressTextField.addTarget(self, action: #selector(emailTextFieldDidChangeText), for: UIControlEvents.editingChanged)
        

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func recover(_ sender: UIButton){
    }
    @IBAction func cancel(_ sender: UIButton){
    }
    
    func emailTextFieldDidChangeText(){
        if emailAddressTextField.text != ""{
            toggleRecoveryInButton(isEnabled: true)
        } else {
            toggleRecoveryInButton(isEnabled: false)
        }

    }
    
    func toggleRecoveryInButton(isEnabled: Bool){
        if isEnabled{
            recoveryButton.isEnabled = isEnabled
            recoveryButton.backgroundColor = UIColor(red: 0, green: 122/256, blue: 255/256, alpha: 1.0)
        } else {
            recoveryButton.isEnabled = isEnabled
            recoveryButton.backgroundColor = UIColor(red: 0, green: 122/256, blue: 255/256, alpha: 0.5)
        }
    }

}
